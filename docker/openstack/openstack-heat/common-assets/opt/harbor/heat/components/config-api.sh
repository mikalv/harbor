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
echo "${OS_DISTRO}: Configuring API"
################################################################################
. /etc/os-container.env
. /opt/harbor/service-hosts.sh
. /opt/harbor/harbor-common.sh
. /opt/harbor/heat/vars.sh
PROC_CORES=$(grep -c ^processor /proc/cpuinfo)
: ${API_WORKERS:="$(( ( $PROC_CORES + 1 ) / 2))"}

################################################################################
check_required_vars HEAT_CONFIG_FILE \
                    OS_DOMAIN \
                    HEAT_API_SVC_PORT \
                    MY_IP \
                    API_WORKERS \
                    HEAT_API_TLS_CA \
                    HEAT_API_TLS_CERT \
                    HEAT_API_TLS_KEY \
                    HEAT_API_SERVICE_HOST_SVC


echo "${OS_DISTRO}: Configuring worker params"
################################################################################
echo "${OS_DISTRO}:    Workers: ${API_WORKERS}"
echo "${OS_DISTRO}:    Port: ${HEAT_API_SVC_PORT}"
echo "${OS_DISTRO}:    Listen: ${MY_IP}"
crudini --set ${HEAT_CONFIG_FILE} heat_api bind_port "${HEAT_API_SVC_PORT}"
crudini --set ${HEAT_CONFIG_FILE} heat_api workers "${API_WORKERS}"
crudini --set ${HEAT_CONFIG_FILE} heat_api bind_host "${MY_IP}"



echo "${OS_DISTRO}: Testing tls certs"
################################################################################
openssl verify -CAfile ${HEAT_API_TLS_CA} ${HEAT_API_TLS_CERT}
CERT_MOD="$(openssl x509 -noout -modulus -in ${HEAT_API_TLS_CERT})"
KEY_MOD="$(openssl rsa -noout -modulus -in ${HEAT_API_TLS_KEY})"
if ! [ "${CERT_MOD}" = "${KEY_MOD}" ]; then
  echo "${OS_DISTRO}: Failure: TLS private key does not match this certificate."
  exit 1
fi
CERT_MOD=""
KEY_MOD=""
echo "${OS_DISTRO}: TLS certs: OK"


echo "${OS_DISTRO}: Configuring TLS params"
################################################################################
crudini --set ${HEAT_CONFIG_FILE} heat_api cert_file "${HEAT_API_TLS_CERT}"
crudini --set ${HEAT_CONFIG_FILE} heat_api key_file "${HEAT_API_TLS_KEY}"


echo "${OS_DISTRO}: Api paste deploy"
################################################################################
crudini --set ${HEAT_CONFIG_FILE} paste_deploy config_file "/etc/heat/heat-api-paste.ini"
