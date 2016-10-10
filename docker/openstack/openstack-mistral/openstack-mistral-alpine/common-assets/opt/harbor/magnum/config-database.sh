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
. /opt/harbor/mistral/vars.sh


################################################################################
check_required_vars MISTRAL_CONFIG_FILE \
                    OS_DOMAIN \
                    MISTRAL_MARIADB_SERVICE_HOST_SVC \
                    MISTRAL_MARIADB_SERVICE_PORT \
                    MISTRAL_DB_CA \
                    MISTRAL_DB_KEY \
                    MISTRAL_DB_CERT \
                    AUTH_MISTRAL_DB_USER \
                    AUTH_MISTRAL_DB_PASSWORD \
                    AUTH_MISTRAL_DB_NAME


################################################################################
crudini --set ${MISTRAL_CONFIG_FILE} database connection \
"mysql+pymysql://${AUTH_MISTRAL_DB_USER}:${AUTH_MISTRAL_DB_PASSWORD}@${MISTRAL_MARIADB_SERVICE_HOST_SVC}:${MISTRAL_MARIADB_SERVICE_PORT}/${AUTH_MISTRAL_DB_NAME}?charset=utf8&ssl_ca=${MISTRAL_DB_CA}&ssl_key=${MISTRAL_DB_KEY}&ssl_cert=${MISTRAL_DB_CERT}&ssl_verify_cert"
