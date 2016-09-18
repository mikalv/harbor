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
. /opt/harbor/raven/vars.sh
. /opt/harbor/raven/env-keystone-auth.sh


echo "${OS_DISTRO}: Keystone config"
################################################################################
export SERVICE_USER="${AUTH_RAVEN_KEYSTONE_USER}"
export SERVICE_TENANT_NAME="${AUTH_RAVEN_KEYSTONE_PROJECT}"
export SERVICE_PASSWORD="${AUTH_RAVEN_KEYSTONE_PASSWORD}"
export SERVICE_CA_CERT="${RAVEN_DB_CA}"
export IDENTITY_URL="https://${KEYSTONE_API_SERVICE_HOST_SVC}/v2.0"


echo "${OS_DISTRO}: Neutron config"
################################################################################
export OS_URL="https://${NEUTRON_API_SERVICE_HOST_SVC}"
export PUBLIC_NET_ID="$(neutron net-show ext-net -f value -c id)"


echo "${OS_DISTRO}: Kube network config"
################################################################################
export SUBNET_POOL="192.168.0.0/16"
export FLANNEL_NET="172.16.0.0/16"
export SERVICE_CLUSTER_IP_RANGE="10.10.0.0/24"

echo "${OS_DISTRO}: Launching container application"
################################################################################
exec /usr/bin/raven --config-file /etc/raven/raven.conf
