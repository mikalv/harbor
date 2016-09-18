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
echo "${OS_DISTRO}: Configuring clients"
################################################################################
. /etc/os-container.env
. /opt/harbor/service-hosts.sh
. /opt/harbor/harbor-common.sh
. /opt/harbor/heat/vars.sh


################################################################################
check_required_vars HEAT_CONFIG_FILE \
                    OS_DOMAIN \
                    HEAT_DB_CA \
                    KEYSTONE_API_SERVICE_HOST_SVC \
                    AUTH_HEAT_KEYSTONE_TRUST_DOMAIN \
                    AUTH_HEAT_KEYSTONE_TRUST_USER \
                    AUTH_HEAT_KEYSTONE_TRUST_PASSWORD \
                    AUTH_HEAT_KEYSTONE_REGION \
                    MEMCACHE_SERVICE_HOST_SVC


################################################################################
crudini --set $HEAT_CONFIG_FILE DEFAULT trusts_delegated_roles "Member"
crudini --set $HEAT_CONFIG_FILE DEFAULT deferred_auth_method "trusts"
crudini --set $HEAT_CONFIG_FILE trustee auth_type "password"
crudini --set $HEAT_CONFIG_FILE trustee auth_section "trustee"


################################################################################
crudini --set ${HEAT_CONFIG_FILE} trustee memcached_servers "${MEMCACHE_SERVICE_HOST_SVC}:11211"
crudini --set ${HEAT_CONFIG_FILE} trustee auth_uri "https://${KEYSTONE_API_SERVICE_HOST_SVC}"
crudini --set ${HEAT_CONFIG_FILE} trustee user_domain_name "${AUTH_HEAT_KEYSTONE_TRUST_DOMAIN}"
crudini --set ${HEAT_CONFIG_FILE} trustee region_name "${AUTH_HEAT_KEYSTONE_REGION}"
crudini --set ${HEAT_CONFIG_FILE} trustee password "${AUTH_HEAT_KEYSTONE_TRUST_PASSWORD}"
crudini --set ${HEAT_CONFIG_FILE} trustee username "${AUTH_HEAT_KEYSTONE_TRUST_USER}"
crudini --set ${HEAT_CONFIG_FILE} trustee auth_url "https://${KEYSTONE_API_SERVICE_HOST_SVC}/v3"
crudini --set ${HEAT_CONFIG_FILE} trustee auth_version "v3"
crudini --set ${HEAT_CONFIG_FILE} trustee signing_dir "/var/cache/heat"
crudini --set ${HEAT_CONFIG_FILE} trustee cafile "${HEAT_DB_CA}"
