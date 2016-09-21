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


tail -f /dev/null
echo "${OS_DISTRO}: Installing pipework to /var/run/harbor/hooks/bin/pipework"
################################################################################
mkdir -p /var/run/harbor/hooks/bin
cat /usr/bin/pipework > /var/run/harbor/hooks/bin/pipework
chmod +x /var/run/harbor/hooks/bin/pipework


echo "${OS_DISTRO}: Installing host hook script to /var/run/harbor/hooks/uplink"
################################################################################
echo $HOSTNAME > /var/run/harbor/neutron/link/downlink

echo "${OS_DISTRO}: Waiting for pipework to give us an interface"
################################################################################
pipework --wait -i eth1


echo "${OS_DISTRO}: Setting Up iptables"
################################################################################
iptables -A FORWARD -i eth1 -o eth0 -j ACCEPT
iptables -t nat -A POSTROUTING -j MASQUERADE


echo "${OS_DISTRO}: Going to sleep"
################################################################################
exec tail -f /dev/null
SUBNET_POOL="192.168.0.0/16"
FLANNEL_NET="172.16.0.0/16"
SERVICE_CLUSTER_IP_RANGE="10.10.0.0/24"

UPLINK_DEV="br-uplink"
UPLINK_IP_CONT="169.254.1.1"
UPLINK_IP_HOST="169.254.1.2"



DOWNLINK_CONTAINER_HOSTNAME=$(cat /var/run/harbor/neutron/link/uplink)
DOWNLINK_CONTAINER=$(docker ps | grep "k8s_neutron-downlink.*.${DOWNLINK_CONTAINER_HOSTNAME}" | awk '{ print $NF }')

echo "${OS_DISTRO}: Cleaning any old uplink config"
################################################################################
ip link set ${UPLINK_DEV} down &>/dev/null || true
ip addr del ${UPLINK_IP_HOST}/30 dev ${UPLINK_DEV} &>/dev/null || true
route del -net ${SUBNET_POOL} gw ${UPLINK_IP_CONT} &>/dev/null || true
route del -net ${SERVICE_CLUSTER_IP_RANGE} gw ${UPLINK_IP_CONT} &>/dev/null || true
brctl delbr ${UPLINK_DEV} &>/dev/null || true


echo "${OS_DISTRO}: Creating up-link"
################################################################################
pipework ${UPLINK_DEV} ${DOWNLINK_CONTAINER} ${UPLINK_IP_CONT}/30
ip addr add ${UPLINK_IP_HOST}/30 dev ${UPLINK_DEV}
ip link set br-uplink up
route add -net ${SUBNET_POOL} gw ${UPLINK_IP_CONT}
route add -net ${SERVICE_CLUSTER_IP_RANGE} gw ${UPLINK_IP_CONT}
