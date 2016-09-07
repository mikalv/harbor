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
echo "${OS_DISTRO}: Configuring api database connection"
################################################################################
. /etc/os-container.env
. /opt/harbor/service-hosts.sh
. /opt/harbor/harbor-common.sh
. /opt/harbor/nova/vars.sh


################################################################################
check_required_vars NOVA_CONFIG_FILE \
                    OS_DOMAIN \
                    NOVA_MARIADB_SERVICE_HOST_SVC \
                    NOVA_MARIADB_SERVICE_PORT \
                    NOVA_DB_CA \
                    NOVA_DB_KEY \
                    NOVA_DB_CERT \
                    AUTH_NOVA_API_DB_USER \
                    AUTH_NOVA_API_DB_PASSWORD \
                    AUTH_NOVA_API_DB_NAME


################################################################################
crudini --set ${NOVA_CONFIG_FILE} api_database connection \
"mysql+pymysql://${AUTH_NOVA_API_DB_USER}:${AUTH_NOVA_API_DB_PASSWORD}@${NOVA_MARIADB_SERVICE_HOST_SVC}:${NOVA_MARIADB_SERVICE_PORT}/${AUTH_NOVA_API_DB_NAME}?charset=utf8&ssl_ca=${NOVA_DB_CA}&ssl_key=${NOVA_DB_KEY}&ssl_cert=${NOVA_DB_CERT}&ssl_verify_cert"
