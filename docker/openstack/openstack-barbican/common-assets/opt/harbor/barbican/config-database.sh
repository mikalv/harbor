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
. /opt/harbor/barbican/vars.sh


################################################################################
check_required_vars BARBICAN_CONFIG_FILE \
                    OS_DOMAIN \
                    BARBICAN_MARIADB_SERVICE_HOST_SVC \
                    BARBICAN_MARIADB_SERVICE_PORT \
                    BARBICAN_DB_CA \
                    BARBICAN_DB_KEY \
                    BARBICAN_DB_CERT \
                    AUTH_BARBICAN_DB_USER \
                    AUTH_BARBICAN_DB_PASSWORD \
                    AUTH_BARBICAN_DB_NAME


################################################################################
crudini --set ${BARBICAN_CONFIG_FILE} DEFAULT sql_connection \
"mysql+pymysql://${AUTH_BARBICAN_DB_USER}:${AUTH_BARBICAN_DB_PASSWORD}@${BARBICAN_MARIADB_SERVICE_HOST_SVC}:${BARBICAN_MARIADB_SERVICE_PORT}/${AUTH_BARBICAN_DB_NAME}?charset=utf8&ssl_ca=${BARBICAN_DB_CA}&ssl_key=${BARBICAN_DB_KEY}&ssl_cert=${BARBICAN_DB_CERT}&ssl_verify_cert"

crudini --set ${BARBICAN_CONFIG_FILE} DEFAULT db_auto_create "False"
