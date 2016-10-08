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
. /opt/harbor/designate/vars.sh


################################################################################
check_required_vars DESIGNATE_CONFIG_FILE \
                    AUTH_DESIGNATE_KEYSTONE_REGION \
                    DESIGNATE_DB_CERT


################################################################################
crudini --set ${DESIGNATE_CONFIG_FILE} network_api:neutron endpoints "${AUTH_DESIGNATE_KEYSTONE_REGION}|https://${NEUTRON_API_SERVICE_HOST}"
crudini --set ${DESIGNATE_CONFIG_FILE} network_api:neutron timeout "30"
# crudini --set $cfg network_api:neutron admin_username "${DESIGNATE_KEYSTONE_USER}"
# crudini --set $cfg network_api:neutron admin_password "${DESIGNATE_KEYSTONE_PASSWORD}"
# crudini --set $cfg network_api:neutron admin_tenant_name "${SERVICE_TENANT_NAME}"
# crudini --set $cfg network_api:neutron auth_url "${KEYSTONE_AUTH_PROTOCOL}://${KEYSTONE_OLD_ADMIN_SERVICE_HOST}:35357/v2.0"
crudini --set ${DESIGNATE_CONFIG_FILE} network_api:neutron insecure "False"
crudini --set ${DESIGNATE_CONFIG_FILE} network_api:neutron auth_strategy "keystone"
crudini --set ${DESIGNATE_CONFIG_FILE} network_api:neutron ca_certificates_file "${DESIGNATE_DB_CERT}"
