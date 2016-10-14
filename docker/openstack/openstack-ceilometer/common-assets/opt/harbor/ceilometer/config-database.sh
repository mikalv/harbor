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
                    GNOCCHI_API_SERVICE_HOST_SVC \
                    GNOCCHI_ARCHIVE_POLICY


################################################################################
crudini --set ${CEILOMETER_CONFIG_FILE} DEFAULT meter_dispatchers "gnocchi"
crudini --set ${CEILOMETER_CONFIG_FILE} DEFAULT event_dispatchers "gnocchi"
# NOTE(gordc): set higher retry in case gnocchi is started after ceilometer on a slow machine
crudini --set ${CEILOMETER_CONFIG_FILE} storage max_retries "20"
# NOTE(gordc): set batching to better handle recording on a slow machine
crudini --set ${CEILOMETER_CONFIG_FILE} collector batch_size "50"
crudini --set ${CEILOMETER_CONFIG_FILE} collector batch_timeout "5"
crudini --set ${CEILOMETER_CONFIG_FILE} dispatcher_gnocchi url "https://${GNOCCHI_API_SERVICE_HOST_SVC}"
crudini --set ${CEILOMETER_CONFIG_FILE} dispatcher_gnocchi archive_policy "${GNOCCHI_ARCHIVE_POLICY}"
crudini --set ${CEILOMETER_CONFIG_FILE} dispatcher_gnocchi filter_service_activity "False"
crudini --set ${CEILOMETER_CONFIG_FILE} DEFAULT dispatcher "gnocchi"
crudini --set ${CEILOMETER_CONFIG_FILE} notification store_events "false"


################################################################################
crudini --set ${CEILOMETER_CONFIG_FILE} database metering_connection "mysql+pymysql://${AUTH_CEILOMETER_DB_USER}:${AUTH_CEILOMETER_DB_PASSWORD}@${CEILOMETER_MARIADB_SERVICE_HOST_SVC}:${CEILOMETER_MARIADB_SERVICE_PORT}/${AUTH_CEILOMETER_DB_NAME}?charset=utf8&ssl_ca=${CEILOMETER_DB_CA}&ssl_key=${CEILOMETER_DB_KEY}&ssl_cert=${CEILOMETER_DB_CERT}&ssl_verify_cert"
sed -r -i 's/meter_dispatchers\ =\ gnocchi/meter_dispatchers\ =\ gnocchi\nmeter_dispatchers\ =\ database/g' /etc/ceilometer/ceilometer.conf


################################################################################
crudini --set ${CEILOMETER_CONFIG_FILE} database event_connection "es://${CEILOMETER_ELS_SERVICE_HOST_SVC}:${CEILOMETER_ELS_SERVICE_PORT}"
sed -r -i 's/event_dispatchers\ =\ gnocchi/event_dispatchers\ =\ gnocchi\nevent_dispatchers\ =\ database/g' /etc/ceilometer/ceilometer.conf
