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
. /opt/harbor/cinder/vars.sh


################################################################################
check_required_vars CINDER_CONFIG_FILE \
                    OS_DOMAIN \
                    CINDER_MARIADB_SERVICE_HOST_SVC \
                    CINDER_MARIADB_SERVICE_PORT \
                    CINDER_DB_CA \
                    CINDER_DB_KEY \
                    CINDER_DB_CERT \
                    AUTH_CINDER_DB_USER \
                    AUTH_CINDER_DB_PASSWORD \
                    AUTH_CINDER_DB_NAME


################################################################################
crudini --set ${CINDER_CONFIG_FILE} database connection \
"mysql+pymysql://${AUTH_CINDER_DB_USER}:${AUTH_CINDER_DB_PASSWORD}@${CINDER_MARIADB_SERVICE_HOST_SVC}:${CINDER_MARIADB_SERVICE_PORT}/${AUTH_CINDER_DB_NAME}?charset=utf8&ssl_ca=${CINDER_DB_CA}&ssl_key=${CINDER_DB_KEY}&ssl_cert=${CINDER_DB_CERT}&ssl_verify_cert"
