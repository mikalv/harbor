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
echo "${OS_DISTRO}: Configuring Glance API"
################################################################################
. /etc/os-container.env
. /opt/harbor/service-hosts.sh
. /opt/harbor/harbor-common.sh
. /opt/harbor/glance/vars.sh
PROC_CORES=$(grep -c ^processor /proc/cpuinfo)
: ${API_WORKERS:="$(( ( $PROC_CORES + 1 ) / 2))"}

################################################################################
check_required_vars GLANCE_CONFIG_FILE \
                    OS_DOMAIN \
                    GLANCE_API_SVC_PORT \
                    MY_IP \
                    API_WORKERS \
                    GLANCE_API_TLS_CA \
                    GLANCE_API_TLS_CERT \
                    GLANCE_API_TLS_KEY \
                    GLANCE_API_SERVICE_HOST_SVC


################################################################################
crudini --set $cfg DEFAULT use_ssl "True"


echo "${OS_DISTRO}: Configuring worker params"
################################################################################
echo "${OS_DISTRO}:    Workers: ${API_WORKERS}"
echo "${OS_DISTRO}:    Port: ${GLANCE_API_SVC_PORT}"
echo "${OS_DISTRO}:    Listen: ${MY_IP}"
crudini --set ${GLANCE_CONFIG_FILE} DEFAULT bind_port "${GLANCE_API_SVC_PORT}"
crudini --set ${GLANCE_CONFIG_FILE} DEFAULT workers "${API_WORKERS}"
crudini --set ${GLANCE_CONFIG_FILE} DEFAULT bind_host "${MY_IP}"



echo "${OS_DISTRO}: Testing tls certs"
################################################################################
openssl verify -CAfile ${GLANCE_API_TLS_CA} ${GLANCE_API_TLS_CERT}
CERT_MOD="$(openssl x509 -noout -modulus -in ${GLANCE_API_TLS_CERT})"
KEY_MOD="$(openssl rsa -noout -modulus -in ${GLANCE_API_TLS_KEY})"
if ! [ "${CERT_MOD}" = "${KEY_MOD}" ]; then
  echo "${OS_DISTRO}: Failure: TLS private key does not match this certificate."
  exit 1
fi
CERT_MOD=""
KEY_MOD=""
echo "${OS_DISTRO}: TLS certs: OK"


echo "${OS_DISTRO}: Configuring TLS params"
################################################################################
crudini --set ${GLANCE_CONFIG_FILE} DEFAULT cert_file "${GLANCE_API_TLS_CERT}"
crudini --set ${GLANCE_CONFIG_FILE} DEFAULT key_file "${GLANCE_API_TLS_KEY}"


echo "${OS_DISTRO}: Api paste deploy"
################################################################################
crudini --set ${GLANCE_CONFIG_FILE} paste_deploy config_file "/etc/glance/glance-api-paste.ini"
