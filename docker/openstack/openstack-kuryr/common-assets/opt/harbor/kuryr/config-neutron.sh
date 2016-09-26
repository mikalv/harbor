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
. /opt/harbor/kuryr/vars.sh


################################################################################
check_required_vars KURYR_CONFIG_FILE \
                    OS_DOMAIN \
                    AUTH_KURYR_KEYSTONE_REGION \
                    AUTH_KURYR_KEYSTONE_DOMAIN \
                    AUTH_KURYR_KEYSTONE_USER \
                    AUTH_KURYR_KEYSTONE_PASSWORD \
                    AUTH_KURYR_KEYSTONE_PROJECT_DOMAIN \
                    AUTH_KURYR_KEYSTONE_PROJECT \
                    KURYR_DB_CA \
                    KEYSTONE_API_SERVICE_HOST_SVC \
                    MEMCACHE_SERVICE_HOST_SVC


################################################################################
crudini --set ${KURYR_CONFIG_FILE} neutron project_domain_name "${AUTH_KURYR_KEYSTONE_PROJECT_DOMAIN}"
crudini --set ${KURYR_CONFIG_FILE} neutron project_name "${AUTH_SERVICE_KEYSTONE_PROJECT}"
crudini --set ${KURYR_CONFIG_FILE} neutron user_domain_name "${AUTH_KURYR_KEYSTONE_DOMAIN}"
crudini --set ${KURYR_CONFIG_FILE} neutron password "${AUTH_KURYR_KEYSTONE_PASSWORD}"
crudini --set ${KURYR_CONFIG_FILE} neutron username "${AUTH_KURYR_KEYSTONE_USER}"
crudini --set ${KURYR_CONFIG_FILE} neutron auth_url "https://${KEYSTONE_API_SERVICE_HOST_SVC}"
crudini --set ${KURYR_CONFIG_FILE} neutron auth_type "password"
crudini --set ${KURYR_CONFIG_FILE} neutron region "${AUTH_KURYR_KEYSTONE_REGION}"
crudini --set ${KURYR_CONFIG_FILE} neutron cafile "${KURYR_DB_CA}"
