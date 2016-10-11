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
. /opt/harbor/gnocchi/vars.sh


################################################################################
check_required_vars GNOCCHI_CONFIG_FILE \
                    OS_DOMAIN \
                    GNOCCHI_MARIADB_SERVICE_HOST_SVC \
                    GNOCCHI_MARIADB_SERVICE_PORT \
                    GNOCCHI_DB_CA \
                    GNOCCHI_DB_KEY \
                    GNOCCHI_DB_CERT \
                    AUTH_GNOCCHI_DB_USER \
                    AUTH_GNOCCHI_DB_PASSWORD \
                    AUTH_GNOCCHI_DB_NAME


################################################################################
crudini --set ${GNOCCHI_CONFIG_FILE} database connection "mysql://${AUTH_GNOCCHI_DB_USER}:${AUTH_GNOCCHI_DB_PASSWORD}@${GNOCCHI_MARIADB_SERVICE_HOST_SVC}:${GNOCCHI_MARIADB_SERVICE_PORT}/${AUTH_GNOCCHI_DB_NAME}?charset=utf8&ssl_ca=${GNOCCHI_DB_CA}&ssl_key=${GNOCCHI_DB_KEY}&ssl_cert=${GNOCCHI_DB_CERT}&ssl_verify_cert"
crudini --set ${GNOCCHI_CONFIG_FILE} indexer url "mysql://${AUTH_GNOCCHI_DB_USER}:${AUTH_GNOCCHI_DB_PASSWORD}@${GNOCCHI_MARIADB_SERVICE_HOST_SVC}:${GNOCCHI_MARIADB_SERVICE_PORT}/${AUTH_GNOCCHI_DB_NAME}?charset=utf8&ssl_ca=${GNOCCHI_DB_CA}&ssl_key=${GNOCCHI_DB_KEY}&ssl_cert=${GNOCCHI_DB_CERT}&ssl_verify_cert"
