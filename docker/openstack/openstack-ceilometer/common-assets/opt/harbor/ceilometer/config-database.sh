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
. /opt/harbor/ceilometer/vars.sh


################################################################################
check_required_vars CEILOMETER_CONFIG_FILE \
                    OS_DOMAIN \
                    CEILOMETER_MARIADB_SERVICE_HOST_SVC \
                    CEILOMETER_MARIADB_SERVICE_PORT \
                    CEILOMETER_DB_CA \
                    CEILOMETER_DB_KEY \
                    CEILOMETER_DB_CERT \
                    AUTH_CEILOMETER_DB_USER \
                    AUTH_CEILOMETER_DB_PASSWORD \
                    AUTH_CEILOMETER_DB_NAME


################################################################################
crudini --set ${CEILOMETER_CONFIG_FILE} database connection \
"mysql+pymysql://${AUTH_CEILOMETER_DB_USER}:${AUTH_CEILOMETER_DB_PASSWORD}@${CEILOMETER_MARIADB_SERVICE_HOST_SVC}:${CEILOMETER_MARIADB_SERVICE_PORT}/${AUTH_CEILOMETER_DB_NAME}?charset=utf8&ssl_ca=${CEILOMETER_DB_CA}&ssl_key=${CEILOMETER_DB_KEY}&ssl_cert=${CEILOMETER_DB_CERT}&ssl_verify_cert"
crudini --set ${CEILOMETER_CONFIG_FILE} database max_overflow "-1"
crudini --set ${CEILOMETER_CONFIG_FILE} database max_pool_size "1000"
