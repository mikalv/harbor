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
echo "${OS_DISTRO}: Configuring api"
################################################################################
. /etc/os-container.env
. /opt/harbor/service-hosts.sh
. /opt/harbor/harbor-common.sh
. /opt/harbor/ceilometer/vars.sh
PROC_CORES=$(grep -c ^processor /proc/cpuinfo)
: ${API_WORKERS:="$(( ( $PROC_CORES + 1 ) / 2))"}


################################################################################
check_required_vars CEILOMETER_CONFIG_FILE \
                    OS_DOMAIN \
                    CEILOMETER_API_SVC_PORT \
                    MY_IP \
                    API_WORKERS \
                    CEILOMETER_HTTPD_CONFIG_FILE


echo "${OS_DISTRO}: Configuring worker params"
################################################################################
crudini --set ${CEILOMETER_CONFIG_FILE} collector workers "${API_WORKERS}"



echo "${OS_DISTRO}: Configuring apache params"
################################################################################
sed -i "s|{{ MY_IP }}|${MY_IP}|g" ${CEILOMETER_HTTPD_CONFIG_FILE}
sed -i "s|{{ CEILOMETER_API_SERVICE_HOST }}|${CEILOMETER_API_SERVICE_HOST}|g" ${CEILOMETER_HTTPD_CONFIG_FILE}
sed -i "s|{{ CEILOMETER_API_SVC_PORT }}|${CEILOMETER_API_SVC_PORT}|g" ${CEILOMETER_HTTPD_CONFIG_FILE}
sed -i "s|{{ CEILOMETER_API_TLS_CERT }}|${CEILOMETER_API_TLS_CERT}|g" ${CEILOMETER_HTTPD_CONFIG_FILE}
sed -i "s|{{ CEILOMETER_API_TLS_KEY }}|${CEILOMETER_API_TLS_KEY}|g" ${CEILOMETER_HTTPD_CONFIG_FILE}
sed -i "s|{{ CEILOMETER_API_TLS_CA }}|${CEILOMETER_API_TLS_CA}|g" ${CEILOMETER_HTTPD_CONFIG_FILE}


echo "${OS_DISTRO}: Moving pod httpd config into place"
################################################################################
cp -rfav $(dirname ${CEILOMETER_HTTPD_CONFIG_FILE})/* /pod$(dirname ${CEILOMETER_HTTPD_CONFIG_FILE})/
