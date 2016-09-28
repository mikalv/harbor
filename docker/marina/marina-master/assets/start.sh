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
: ${OS_DISTRO:="HarborOS: Marina"}
echo "${OS_DISTRO}: Starting Marina"
################################################################################
echo ""
echo ""
cat /splash.txt || true
echo ""
echo ""
export OS_DOMAIN=$(crudini --get /etc/harbor/network.conf DEFAULT os_domain)

HARBOR_SERVICE_LIST="harbor-auth.service \
                    harbor-kubernetes.service \
                    harbor-etcd.service \
                    harbor-loadbalancer.service \
                    harbor-ovn.service \
                    harbor-memcached.service \
                    harbor-messaging.service \
                    harbor-ipsilon.service \
                    harbor-keystone.service \
                    harbor-api.service \
                    harbor-neutron.service \
                    harbor-glance.service \
                    harbor-cinder.service \
                    harbor-nova.service \
                    harbor-heat.service \
                    harbor-murano.service"


HOST_USER=harbor
echo "${OS_DISTRO}: Setting up user ${HOST_USER}"
################################################################################
groupadd ${HOST_USER} -g 1000 &> /dev/null || true
adduser -u 1000 -g ${HOST_USER} --create-home ${HOST_USER} &> /dev/null || true
usermod -a -G wheel harbor &> /dev/null || true
chmod 0600 /etc/shadow &> /dev/null || true
sed -i "s|^harbor:.*|$(grep "^${HOST_USER}" /etc/host-shadow)|" /etc/shadow &> /dev/null || true
chmod 0400 /etc/shadow &> /dev/null || true


echo "${OS_DISTRO}: Starting cockpit"
################################################################################
systemctl unmask systemd-logind.service
systemctl restart systemd-logind.service
rm -f /run/nologin
systemctl restart cockpit.service


echo "${OS_DISTRO}: Testing kube connection"
################################################################################
until kubectl cluster-info
do
  echo "${OS_DISTRO}: Waiting for kube"
  sleep 60s
done


echo "${OS_DISTRO}: Creating all namespaces"
################################################################################
kubectl create -R -f /opt/harbor/kubernetes/namespaces &> /dev/null || true
kubectl get -R -f /opt/harbor/kubernetes/namespaces || true


echo "${OS_DISTRO}: Creating all ingress rules"
################################################################################
find /opt/harbor/kubernetes/ingress -type f -exec sed -i.bak "s/{{ OS_DOMAIN }}/${OS_DOMAIN}/g" {} \;
kubectl create -R -f /opt/harbor/kubernetes/ingress &> /dev/null || true
kubectl get -R -f /opt/harbor/kubernetes/ingress


echo "${OS_DISTRO}: Managing Kubernetes service"
################################################################################
start_systemd_harbor_service () {
  SYSTEMD_SERVICE=$1
  echo "${OS_DISTRO}: Starting service ${SYSTEMD_SERVICE}"
  ##############################################################################
  systemctl enable ${SYSTEMD_SERVICE}
  systemctl start ${SYSTEMD_SERVICE}
}

for HARBOR_SERVICE in ${HARBOR_SERVICE_LIST}; do
  systemctl enable ${HARBOR_SERVICE}
done

for HARBOR_SERVICE in ${HARBOR_SERVICE_LIST}; do
  start_systemd_harbor_service ${HARBOR_SERVICE}
done


echo "${OS_DISTRO}: Finished management bootstrapping"
################################################################################
