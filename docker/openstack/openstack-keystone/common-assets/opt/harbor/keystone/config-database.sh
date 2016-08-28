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
. /opt/harbor/keystone/vars.sh


################################################################################
check_required_vars KEYSTONE_CONFIG_FILE \
                    OS_DOMAIN \
                    KEYSTONE_MARIADB_SERVICE_HOST_SVC \
                    KEYSTONE_MARIADB_SERVICE_PORT \
                    KEYSTONE_DB_CA \
                    KEYSTONE_DB_KEY \
                    KEYSTONE_DB_CERT \
                    AUTH_KEYSTONE_DB_USER \
                    AUTH_KEYSTONE_DB_PASSWORD \
                    AUTH_KEYSTONE_DB_NAME


################################################################################
crudini --set ${KEYSTONE_CONFIG_FILE} database connection \
"mysql+pymysql://${AUTH_KEYSTONE_DB_USER}:${AUTH_KEYSTONE_DB_PASSWORD}@${KEYSTONE_MARIADB_SERVICE_HOST_SVC}:${KEYSTONE_MARIADB_SERVICE_PORT}/${AUTH_KEYSTONE_DB_NAME}?charset=utf8&ssl_ca=${KEYSTONE_DB_CA}&ssl_key=${KEYSTONE_DB_KEY}&ssl_cert=${KEYSTONE_DB_CERT}&ssl_verify_cert"
