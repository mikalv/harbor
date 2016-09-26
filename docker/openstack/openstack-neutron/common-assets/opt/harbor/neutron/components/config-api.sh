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
echo "${OS_DISTRO}: Configuring Neutron API"
################################################################################
. /etc/os-container.env
. /opt/harbor/service-hosts.sh
. /opt/harbor/harbor-common.sh
. /opt/harbor/neutron/vars.sh
PROC_CORES=$(grep -c ^processor /proc/cpuinfo)
: ${API_WORKERS:="$(( ( $PROC_CORES + 1 ) / 2))"}

################################################################################
check_required_vars NEUTRON_CONFIG_FILE \
                    OS_DOMAIN \
                    NEUTRON_API_SVC_PORT \
                    MY_IP \
                    API_WORKERS \
                    NEUTRON_API_TLS_CA \
                    NEUTRON_API_TLS_CERT \
                    NEUTRON_API_TLS_KEY \
                    NEUTRON_API_SERVICE_HOST_SVC


################################################################################
crudini --set $cfg DEFAULT use_ssl "True"


echo "${OS_DISTRO}: Configuring worker params"
################################################################################
echo "${OS_DISTRO}:    Workers: ${API_WORKERS}"
echo "${OS_DISTRO}:    Host: ${NEUTRON_API_SERVICE_HOST_SVC}"
echo "${OS_DISTRO}:    Port: ${NEUTRON_API_SVC_PORT}"
echo "${OS_DISTRO}:    Listen: ${MY_IP}"
crudini --set ${NEUTRON_CONFIG_FILE} DEFAULT host "${NEUTRON_API_SERVICE_HOST_SVC}"
crudini --set ${NEUTRON_CONFIG_FILE} DEFAULT bind_port "${NEUTRON_API_SVC_PORT}"
crudini --set ${NEUTRON_CONFIG_FILE} DEFAULT api_workers "${API_WORKERS}"
crudini --set ${NEUTRON_CONFIG_FILE} DEFAULT bind_host "${MY_IP}"
crudini --set ${NEUTRON_CONFIG_FILE} DEFAULT web_framework "legacy"



echo "${OS_DISTRO}: Testing tls certs"
################################################################################
openssl verify -CAfile ${NEUTRON_API_TLS_CA} ${NEUTRON_API_TLS_CERT}
CERT_MOD="$(openssl x509 -noout -modulus -in ${NEUTRON_API_TLS_CERT})"
KEY_MOD="$(openssl rsa -noout -modulus -in ${NEUTRON_API_TLS_KEY})"
if ! [ "${CERT_MOD}" = "${KEY_MOD}" ]; then
  echo "${OS_DISTRO}: Failure: TLS private key does not match this certificate."
  exit 1
fi
CERT_MOD=""
KEY_MOD=""
echo "${OS_DISTRO}: TLS certs: OK"


echo "${OS_DISTRO}: Configuring TLS params"
################################################################################
crudini --set ${NEUTRON_CONFIG_FILE} DEFAULT use_ssl "True"
crudini --set ${NEUTRON_CONFIG_FILE} DEFAULT ssl_cert_file "${NEUTRON_API_TLS_CERT}"
crudini --set ${NEUTRON_CONFIG_FILE} DEFAULT ssl_key_file "${NEUTRON_API_TLS_KEY}"
