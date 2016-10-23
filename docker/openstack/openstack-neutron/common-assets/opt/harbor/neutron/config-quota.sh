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
echo "${OS_DISTRO}: Configuring quotas"
################################################################################
. /etc/os-container.env
. /opt/harbor/service-hosts.sh
. /opt/harbor/harbor-common.sh
. /opt/harbor/neutron/vars.sh


################################################################################
check_required_vars NEUTRON_CONFIG_FILE \
                    OS_DOMAIN


################################################################################
crudini --set ${NEUTRON_CONFIG_FILE} QUOTAS default_quota "-1"
crudini --set ${NEUTRON_CONFIG_FILE} QUOTAS quota_driver "neutron.db.quota.driver.DbQuotaDriver"
crudini --set ${NEUTRON_CONFIG_FILE} QUOTAS quota_floatingip "50"
crudini --set ${NEUTRON_CONFIG_FILE} QUOTAS quota_health_monitor "-1"
crudini --set ${NEUTRON_CONFIG_FILE} QUOTAS quota_healthmonitor "-1"
crudini --set ${NEUTRON_CONFIG_FILE} QUOTAS quota_listener "-1"
crudini --set ${NEUTRON_CONFIG_FILE} QUOTAS quota_loadbalancer "50"
crudini --set ${NEUTRON_CONFIG_FILE} QUOTAS quota_member "-1"
crudini --set ${NEUTRON_CONFIG_FILE} QUOTAS quota_network "100"
crudini --set ${NEUTRON_CONFIG_FILE} QUOTAS quota_pool "100"
crudini --set ${NEUTRON_CONFIG_FILE} QUOTAS quota_port "500"
crudini --set ${NEUTRON_CONFIG_FILE} QUOTAS quota_rbac_policy "10"
crudini --set ${NEUTRON_CONFIG_FILE} QUOTAS quota_router "10"
crudini --set ${NEUTRON_CONFIG_FILE} QUOTAS quota_security_group "100"
crudini --set ${NEUTRON_CONFIG_FILE} QUOTAS quota_security_group_rule "1000"
crudini --set ${NEUTRON_CONFIG_FILE} QUOTAS quota_subnet "100"
crudini --set ${NEUTRON_CONFIG_FILE} QUOTAS quota_vip "100"
crudini --set ${NEUTRON_CONFIG_FILE} QUOTAS track_quota_usage "True"
