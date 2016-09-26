#!/bin/bash

# Copyright 2016 Port Direct
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -e
echo "${OS_DISTRO}: Launching"
################################################################################
. /etc/os-container.env
. /opt/harbor/service-hosts.sh
. /opt/harbor/harbor-common.sh
. /opt/harbor/kuryr/vars.sh
. /opt/harbor/kuryr/manage/env-keystone-auth.sh


################################################################################
check_required_vars UPLINK_NET_NAME \
                    UPLINK_NET \
                    UPLINK_IP_HOST \
                    UPLINK_NET_NAME \
                    UPLINK_KUBE_NAMESPACE \
                    UPLINK_IMAGE \
                    SUBNET_POOL \
                    SERVICE_CLUSTER_IP_RANGE \
                    UPLINK_IP_CONT


echo "${OS_DISTRO}: Managing local uplink network"
################################################################################
docker network inspect ${UPLINK_NET_NAME} || docker network create \
  --driver=bridge \
  --subnet=${UPLINK_NET} \
  --ip-range=${UPLINK_NET} \
  --gateway=${UPLINK_IP_HOST} \
  ${UPLINK_NET_NAME}


echo "${OS_DISTRO}: Managing ${UPLINK_KUBE_NAMESPACE} network"
################################################################################
NET_ID=$(openstack network show ${UPLINK_KUBE_NAMESPACE} -f value -c id)
SUBNET_ID=$(openstack subnet show ${UPLINK_KUBE_NAMESPACE}-subnet -f value -c id)
SUBNET_GATEWAY=$(openstack subnet show ${SUBNET_ID} -f value -c gateway_ip)
SUBNET_CIDR=$(openstack subnet show ${SUBNET_ID} -f value -c cidr)
docker network inspect ${UPLINK_KUBE_NAMESPACE} || docker network create \
  -d kuryr \
  --ipam-driver=kuryr \
  --subnet=${SUBNET_CIDR} \
  --gateway=${SUBNET_GATEWAY} \
  -o neutron.net.uuid=${NET_ID} ${UPLINK_KUBE_NAMESPACE}


echo "${OS_DISTRO}: Launching Router Container"
################################################################################
docker rm -f "${UPLINK_NET_NAME}-router" &> /dev/null || true
UPLINK_CONTAINER=$(docker run \
        --name "${UPLINK_NET_NAME}-router" \
        -d \
        --net=${UPLINK_KUBE_NAMESPACE} \
        --cap-add NET_ADMIN \
        --entrypoint /router \
        ${UPLINK_IMAGE})
docker network connect ${UPLINK_NET_NAME} ${UPLINK_CONTAINER}


echo "${OS_DISTRO}: Managing Host Routes"
################################################################################
route add -net ${SUBNET_POOL} gw ${UPLINK_IP_CONT} &> /dev/null || true
route add -net ${SERVICE_CLUSTER_IP_RANGE} gw ${UPLINK_IP_CONT} &> /dev/null || true
route add -net ${SERVICE_CLUSTER_IP_RANGE} gw ${UPLINK_IP_CONT} &> /dev/null || true


echo "${OS_DISTRO}: Setting Up access to the pubic network"
################################################################################
ip addr add ${PUBLIC_GATEWAY_IP} dev ${EXTERNAL_BRIDGE} || true
ip link set up ${EXTERNAL_BRIDGE}
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE


RAVEN_DEFAULT_SG="raven-default-sg"
echo "${OS_DISTRO}: Managing security group: ${RAVEN_DEFAULT_SG}"
################################################################################
RAVEN_DEFAULT_SG_ID=$(openstack security group show ${RAVEN_DEFAULT_SG} -f value -c id)


# Add the port we hacked into the raven subnet to the raven sg
ROUTER_ENPOINT=$(docker inspect ${UPLINK_NET_NAME}-router | \
  jq -r ".[0].NetworkSettings.Networks.\"${UPLINK_KUBE_NAMESPACE}\".EndpointID")
neutron port-update --security-group ${RAVEN_DEFAULT_SG_ID} "${ROUTER_ENPOINT}-port"


# Then add the current host and uplink ip to the raven sg, to allow the host direct access to the cluster
for IP_ADDR in ${MY_IP} ${UPLINK_IP_CONT}; do
  for PROTO in tcp udp; do
    openstack security group show ${RAVEN_DEFAULT_SG_ID} -f value -c rules | \
      grep "remote_ip_prefix=\'${IP_ADDR}/32\'" | \
      grep -q "protocol=\'${PROTO}\'" || openstack security group rule create \
            --ingress \
            --ethertype IPv4 \
            --protocol ${PROTO} \
            --dst-port 1:65535 \
            --src-ip ${IP_ADDR}/32 \
            ${RAVEN_DEFAULT_SG_ID}
  done
  PROTO=icmp
  openstack security group show ${RAVEN_DEFAULT_SG_ID} -f value -c rules | \
    grep "remote_ip_prefix=\'${IP_ADDR}/32\'" | \
    grep -q "protocol=\'${PROTO}\'" || openstack security group rule create \
          --ingress \
          --ethertype IPv4 \
          --protocol ${PROTO} \
          --src-ip ${IP_ADDR}/32 \
          ${RAVEN_DEFAULT_SG_ID}
done


echo "${OS_DISTRO}: Monitoring container: ${UPLINK_CONTAINER}"
################################################################################
exec docker wait ${UPLINK_CONTAINER}
