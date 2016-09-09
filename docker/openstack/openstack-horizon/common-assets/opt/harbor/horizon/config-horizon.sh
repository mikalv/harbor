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
echo "${OS_DISTRO}: Configuring horizon"
################################################################################
. /etc/os-container.env
. /opt/harbor/service-hosts.sh
. /opt/harbor/harbor-common.sh
. /opt/harbor/horizon/vars.sh


################################################################################
check_required_vars OS_DOMAIN \
                    API_CONFIG_FILE \
                    API_CONFIG_FILE_TEMPLATE \
                    KEYSTONE_API_SERVICE_HOST_SVC \
                    API_DB_KEY \
                    API_DB_CERT \
                    API_DB_CA \
                    API_MARIADB_SERVICE_HOST_SVC \
                    API_MARIADB_SERVICE_PORT \
                    AUTH_API_DB_PASSWORD \
                    AUTH_API_DB_USER \
                    AUTH_API_DB_NAME \
                    MEMCACHE_SERVICE_HOST_SVC \
                    API_TLS_CA

################################################################################
cat ${API_CONFIG_FILE_TEMPLATE} > ${API_CONFIG_FILE}
cat ${API_TLS_CA} >> /etc/ssl/certs/ca-bundle.crt


################################################################################
sed -i "s|{{ OS_DOMAIN }}|${OS_DOMAIN}|g" ${API_CONFIG_FILE}


################################################################################
sed -i "s|{{ KEYSTONE_API_SERVICE_HOST_SVC }}|${KEYSTONE_API_SERVICE_HOST_SVC}|g" ${API_CONFIG_FILE}
sed -i "s|{{ API_TLS_CA }}|${API_TLS_CA}|g" ${API_CONFIG_FILE}


################################################################################
sed -i "s|{{ API_DB_KEY }}|${API_DB_KEY}|g" ${API_CONFIG_FILE}
sed -i "s|{{ API_DB_CERT }}|${API_DB_CERT}|g" ${API_CONFIG_FILE}
sed -i "s|{{ API_DB_CA }}|${API_DB_CA}|g" ${API_CONFIG_FILE}
sed -i "s|{{ API_MARIADB_SERVICE_HOST_SVC }}|${API_MARIADB_SERVICE_HOST_SVC}|g" ${API_CONFIG_FILE}
sed -i "s|{{ API_MARIADB_SERVICE_PORT }}|${API_MARIADB_SERVICE_PORT}|g" ${API_CONFIG_FILE}
sed -i "s|{{ AUTH_API_DB_PASSWORD }}|${AUTH_API_DB_PASSWORD}|g" ${API_CONFIG_FILE}
sed -i "s|{{ AUTH_API_DB_USER }}|${AUTH_API_DB_USER}|g" ${API_CONFIG_FILE}
sed -i "s|{{ AUTH_API_DB_NAME }}|${AUTH_API_DB_NAME}|g" ${API_CONFIG_FILE}


################################################################################
sed -i "s|{{ MEMCACHE_SERVICE_HOST_SVC }}|${MEMCACHE_SERVICE_HOST_SVC}|g" ${API_CONFIG_FILE}
