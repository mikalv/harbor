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
echo "${OS_DISTRO}: Configuring statsd"
################################################################################
. /etc/os-container.env
. /opt/harbor/service-hosts.sh
. /opt/harbor/harbor-common.sh
. /opt/harbor/gnocchi/vars.sh
PROC_CORES=$(grep -c ^processor /proc/cpuinfo)
: ${API_WORKERS:="$(( ( $PROC_CORES + 1 ) / 2))"}


################################################################################
check_required_vars GNOCCHI_CONFIG_FILE \
                    OS_DOMAIN \
                    MY_IP \
                    API_WORKERS \
                    AUTH_GNOCCHI_STATSD_RESOURCE_ID \
                    AUTH_GNOCCHI_STATSD_PROJECT_ID \
                    AUTH_GNOCCHI_STATSD_USER_ID \
                    GNOCCHI_STATSD_SVC_PORT


################################################################################
crudini --set ${GNOCCHI_CONFIG_FILE} statsd host "${MY_IP}"
crudini --set ${GNOCCHI_CONFIG_FILE} statsd port "${GNOCCHI_STATSD_SVC_PORT}"


################################################################################
crudini --set ${GNOCCHI_CONFIG_FILE} statsd resource_id "${AUTH_GNOCCHI_STATSD_RESOURCE_ID}"
crudini --set ${GNOCCHI_CONFIG_FILE} statsd project_id "${AUTH_GNOCCHI_STATSD_PROJECT_ID}"
crudini --set ${GNOCCHI_CONFIG_FILE} statsd user_id "${AUTH_GNOCCHI_STATSD_USER_ID}"
