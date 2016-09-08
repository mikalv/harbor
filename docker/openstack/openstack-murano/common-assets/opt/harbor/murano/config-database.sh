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
. /opt/harbor/murano/vars.sh


################################################################################
check_required_vars MURANO_CONFIG_FILE \
                    OS_DOMAIN \
                    MURANO_MARIADB_SERVICE_HOST_SVC \
                    MURANO_MARIADB_SERVICE_PORT \
                    MURANO_DB_CA \
                    MURANO_DB_KEY \
                    MURANO_DB_CERT \
                    AUTH_MURANO_DB_USER \
                    AUTH_MURANO_DB_PASSWORD \
                    AUTH_MURANO_DB_NAME


################################################################################
crudini --set ${MURANO_CONFIG_FILE} database connection \
"mysql+pymysql://${AUTH_MURANO_DB_USER}:${AUTH_MURANO_DB_PASSWORD}@${MURANO_MARIADB_SERVICE_HOST_SVC}:${MURANO_MARIADB_SERVICE_PORT}/${AUTH_MURANO_DB_NAME}?charset=utf8&ssl_ca=${MURANO_DB_CA}&ssl_key=${MURANO_DB_KEY}&ssl_cert=${MURANO_DB_CERT}&ssl_verify_cert"
