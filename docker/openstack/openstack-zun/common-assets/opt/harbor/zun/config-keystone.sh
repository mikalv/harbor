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
echo "${OS_DISTRO}: Configuring keystone"
################################################################################
. /etc/os-container.env
. /opt/harbor/service-hosts.sh
. /opt/harbor/harbor-common.sh
. /opt/harbor/zun/vars.sh


################################################################################
check_required_vars ZUN_CONFIG_FILE \
                    OS_DOMAIN \
                    AUTH_ZUN_KEYSTONE_REGION \
                    AUTH_ZUN_KEYSTONE_DOMAIN \
                    AUTH_ZUN_KEYSTONE_USER \
                    AUTH_ZUN_KEYSTONE_PASSWORD \
                    AUTH_ZUN_KEYSTONE_PROJECT_DOMAIN \
                    AUTH_ZUN_KEYSTONE_PROJECT \
                    ZUN_DB_CA \
                    KEYSTONE_API_SERVICE_HOST_SVC \
                    MEMCACHE_SERVICE_HOST_SVC


################################################################################
crudini --set ${ZUN_CONFIG_FILE} keystone_authtoken memcached_servers "${MEMCACHE_SERVICE_HOST_SVC}:11211"
crudini --set ${ZUN_CONFIG_FILE} keystone_authtoken memcached_servers "memcached.os-memcached.svc.${OS_DOMAIN}:11211"
crudini --set ${ZUN_CONFIG_FILE} keystone_authtoken auth_uri "https://${KEYSTONE_API_SERVICE_HOST_SVC}:5000"
crudini --set ${ZUN_CONFIG_FILE} keystone_authtoken project_domain_name "${AUTH_ZUN_KEYSTONE_PROJECT_DOMAIN}"
crudini --set ${ZUN_CONFIG_FILE} keystone_authtoken project_name "${AUTH_ZUN_KEYSTONE_PROJECT}"
crudini --set ${ZUN_CONFIG_FILE} keystone_authtoken user_domain_name "${AUTH_ZUN_KEYSTONE_DOMAIN}"
crudini --set ${ZUN_CONFIG_FILE} keystone_authtoken region_name "${AUTH_ZUN_KEYSTONE_REGION}"
crudini --set ${ZUN_CONFIG_FILE} keystone_authtoken password "${AUTH_ZUN_KEYSTONE_PASSWORD}"
crudini --set ${ZUN_CONFIG_FILE} keystone_authtoken username "${AUTH_ZUN_KEYSTONE_USER}"
crudini --set ${ZUN_CONFIG_FILE} keystone_authtoken auth_url "https://${KEYSTONE_API_SERVICE_HOST_SVC}:35357/v3"
crudini --set ${ZUN_CONFIG_FILE} keystone_authtoken auth_type "password"
crudini --set ${ZUN_CONFIG_FILE} keystone_authtoken auth_version "v3"
crudini --set ${ZUN_CONFIG_FILE} keystone_authtoken signing_dir "/var/cache/zun"
crudini --set ${ZUN_CONFIG_FILE} keystone_authtoken cafile "${ZUN_DB_CA}"
