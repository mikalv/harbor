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
echo "${OS_DISTRO}: Configuring neutron"
################################################################################
. /etc/os-container.env
. /opt/harbor/service-hosts.sh
. /opt/harbor/harbor-common.sh
. /opt/harbor/nova/vars.sh


################################################################################
check_required_vars NOVA_CONFIG_FILE \
                    OS_DOMAIN \
                    AUTH_NOVA_KEYSTONE_REGION \
                    AUTH_NOVA_KEYSTONE_DOMAIN \
                    AUTH_NOVA_KEYSTONE_USER \
                    AUTH_NOVA_KEYSTONE_PASSWORD \
                    AUTH_NOVA_KEYSTONE_PROJECT_DOMAIN \
                    AUTH_NOVA_KEYSTONE_PROJECT \
                    NOVA_DB_CA \
                    KEYSTONE_API_SERVICE_HOST_SVC \
                    MEMCACHE_SERVICE_HOST_SVC \
                    NEUTRON_API_SERVICE_HOST_SVC \
                    NEUTRON_API_SVC_PORT


################################################################################
crudini --set ${NOVA_CONFIG_FILE} DEFAULT use_neutron "True"
crudini --set ${NOVA_CONFIG_FILE} neutron url "https://${NEUTRON_API_SERVICE_HOST_SVC}:${NEUTRON_API_SVC_PORT}"


################################################################################
crudini --set ${NOVA_CONFIG_FILE} DEFAULT default_floating_pool "public"


################################################################################
crudini --set ${NOVA_CONFIG_FILE} DEFAULT firewall_driver "nova.virt.firewall.NoopFirewallDriver"


################################################################################
crudini --set ${NOVA_CONFIG_FILE} neutron service_metadata_proxy "True"


################################################################################
crudini --set ${NOVA_CONFIG_FILE} DEFAULT force_dhcp_release "True"
crudini --set ${NOVA_CONFIG_FILE} DEFAULT vif_plugging_timeout "300"
crudini --set ${NOVA_CONFIG_FILE} DEFAULT vif_plugging_is_fatal "True"
crudini --set ${NOVA_CONFIG_FILE} vif_plug_ovs_privileged helper_command "sudo nova-rootwrap $rootwrap_config privsep-helper --config-file ${NOVA_CONFIG_FILE}"
crudini --set ${NOVA_CONFIG_FILE} vif_plug_linux_bridge_privileged helper_command "sudo nova-rootwrap $rootwrap_config privsep-helper --config-file ${NOVA_CONFIG_FILE}"


################################################################################
crudini --set ${NOVA_CONFIG_FILE} neutron auth_section "keystone_neutron"
crudini --set ${NOVA_CONFIG_FILE} neutron cafile "${NOVA_DB_CA}"
crudini --set ${NOVA_CONFIG_FILE} neutron ovs_bridge "br-int"


################################################################################
crudini --set ${NOVA_CONFIG_FILE} keystone_neutron memcached_servers "${MEMCACHE_SERVICE_HOST_SVC}:11211"
crudini --set ${NOVA_CONFIG_FILE} keystone_neutron auth_uri "https://${KEYSTONE_API_SERVICE_HOST_SVC}:5000"
crudini --set ${NOVA_CONFIG_FILE} keystone_neutron project_domain_name "${AUTH_NOVA_KEYSTONE_PROJECT_DOMAIN}"
crudini --set ${NOVA_CONFIG_FILE} keystone_neutron project_name "${AUTH_NOVA_KEYSTONE_PROJECT}"
crudini --set ${NOVA_CONFIG_FILE} keystone_neutron user_domain_name "${AUTH_NOVA_KEYSTONE_DOMAIN}"
crudini --set ${NOVA_CONFIG_FILE} keystone_neutron region_name "${AUTH_NOVA_KEYSTONE_REGION}"
crudini --set ${NOVA_CONFIG_FILE} keystone_neutron password "${AUTH_NOVA_KEYSTONE_PASSWORD}"
crudini --set ${NOVA_CONFIG_FILE} keystone_neutron username "${AUTH_NOVA_KEYSTONE_USER}"
crudini --set ${NOVA_CONFIG_FILE} keystone_neutron auth_url "https://${KEYSTONE_API_SERVICE_HOST_SVC}:35357/v3"
crudini --set ${NOVA_CONFIG_FILE} keystone_neutron auth_type "password"
crudini --set ${NOVA_CONFIG_FILE} keystone_neutron auth_version "v3"
crudini --set ${NOVA_CONFIG_FILE} keystone_neutron signing_dir "/var/cache/nova"
crudini --set ${NOVA_CONFIG_FILE} keystone_neutron cafile "${NOVA_DB_CA}"
