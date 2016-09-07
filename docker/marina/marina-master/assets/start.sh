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
echo "${OS_DISTRO}: Starting Marina"
################################################################################
echo ""
echo ""
cat /splash.txt || true
echo ""
echo ""

echo "${OS_DISTRO}: Creating All namespaces"
################################################################################
until kubectl cluster-info
do
  echo "${OS_DISTRO}: Waiting for kube"
  sleep 60s
done
kubectl create -R -f /opt/harbor/kubernetes/namespaces || true


echo "${OS_DISTRO}: Managing Service Auth Params"
################################################################################
/usr/bin/harbor-service-manage-auth


echo "${OS_DISTRO}: Managing Kubernetes service"
################################################################################
harbor-service-update kubernetes


echo "${OS_DISTRO}: Managing memcached service"
################################################################################
harbor-service-update memcached


echo "${OS_DISTRO}: Managing messaging service"
################################################################################
harbor-service-update messaging


echo "${OS_DISTRO}: Managing ovn service"
################################################################################
harbor-service-update ovn


echo "${OS_DISTRO}: Managing ipsilon service"
################################################################################
harbor-service-update ipsilon


echo "${OS_DISTRO}: Managing keystone service"
################################################################################
harbor-service-update keystone


echo "${OS_DISTRO}: Managing neutron service"
################################################################################
harbor-service-update neutron


echo "${OS_DISTRO}: Managing (horizon) api service"
################################################################################
harbor-service-update api


echo "${OS_DISTRO}: Managing loadbalancer service"
################################################################################
harbor-service-update loadbalancer


echo "${OS_DISTRO}: Managing cinder service"
################################################################################
harbor-service-update cinder


echo "${OS_DISTRO}: Managing glance service"
################################################################################
harbor-service-update glance


echo "${OS_DISTRO}: Managing nova service"
################################################################################
harbor-service-update nova


echo "${OS_DISTRO}: Managing heat service"
################################################################################
harbor-service-update heat


echo "${OS_DISTRO}: Managing murano service"
################################################################################
harbor-service-update murano


echo "${OS_DISTRO}: Finished management bootstrapping"
################################################################################
tail -f /dev/null
