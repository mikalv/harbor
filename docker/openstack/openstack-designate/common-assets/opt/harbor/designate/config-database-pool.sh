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
echo "${OS_DISTRO}: Configuring database connection"
################################################################################
. /etc/os-container.env
. /opt/harbor/service-hosts.sh
. /opt/harbor/harbor-common.sh
. /opt/harbor/designate/vars.sh


################################################################################
check_required_vars DESIGNATE_CONFIG_FILE \
                    OS_DOMAIN \
                    DESIGNATE_MARIADB_SERVICE_HOST_SVC \
                    DESIGNATE_MARIADB_SERVICE_PORT \
                    DESIGNATE_DB_CA \
                    DESIGNATE_DB_KEY \
                    DESIGNATE_DB_CERT \
                    AUTH_DESIGNATE_POOL_DB_USER \
                    AUTH_DESIGNATE_POOL_DB_PASSWORD \
                    AUTH_DESIGNATE_POOL_DB_NAME


################################################################################
crudini --set ${DESIGNATE_CONFIG_FILE} service:pool_manager cache_driver "sqlalchemy"
crudini --set ${DESIGNATE_CONFIG_FILE} pool_manager_cache:sqlalchemy connection \
"mysql+pymysql://${AUTH_DESIGNATE_POOL_DB_USER}:${AUTH_DESIGNATE_POOL_DB_PASSWORD}@${DESIGNATE_MARIADB_SERVICE_HOST_SVC}:${DESIGNATE_MARIADB_SERVICE_PORT}/${AUTH_DESIGNATE_POOL_DB_NAME}?charset=utf8&ssl_ca=${DESIGNATE_DB_CA}&ssl_key=${DESIGNATE_DB_KEY}&ssl_cert=${DESIGNATE_DB_CERT}&ssl_verify_cert"
