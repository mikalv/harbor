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
echo "${OS_DISTRO}: Configuring Nova API"
################################################################################
. /etc/os-container.env
. /opt/harbor/service-hosts.sh
. /opt/harbor/harbor-common.sh
. /opt/harbor/nova/vars.sh
PROC_CORES=$(grep -c ^processor /proc/cpuinfo)
: ${API_WORKERS:="$(( ( $PROC_CORES + 1 ) / 2))"}

################################################################################
check_required_vars NOVA_CONFIG_FILE \
                    OS_DOMAIN \
                    NOVA_API_SVC_PORT \
                    MY_IP \
                    API_WORKERS \
                    NOVA_API_TLS_CA \
                    NOVA_API_TLS_CERT \
                    NOVA_API_TLS_KEY


################################################################################
crudini --set ${NOVA_CONFIG_FILE} DEFAULT enabled_apis ""
crudini --set ${NOVA_CONFIG_FILE} DEFAULT enabled_ssl_apis "osapi_compute"
crudini --set ${NOVA_CONFIG_FILE} DEFAULT api_paste_config "api-paste.ini"


echo "${OS_DISTRO}: Configuring worker params"
################################################################################
echo "${OS_DISTRO}:    Workers: ${API_WORKERS}"
echo "${OS_DISTRO}:    Port: ${NOVA_API_SVC_PORT}"
echo "${OS_DISTRO}:    Listen: ${MY_IP}"
crudini --set ${NOVA_CONFIG_FILE} DEFAULT osapi_compute_listen_port "${NOVA_API_SVC_PORT}"
crudini --set ${NOVA_CONFIG_FILE} DEFAULT osapi_compute_workers "${API_WORKERS}"
crudini --set ${NOVA_CONFIG_FILE} DEFAULT osapi_compute_listen "${MY_IP}"


echo "${OS_DISTRO}: Testing tls certs"
################################################################################
openssl verify -CAfile ${NOVA_API_TLS_CA} ${NOVA_API_TLS_CERT}
CERT_MOD="$(openssl x509 -noout -modulus -in ${NOVA_API_TLS_CERT})"
KEY_MOD="$(openssl rsa -noout -modulus -in ${NOVA_API_TLS_KEY})"
if ! [ "${CERT_MOD}" = "${KEY_MOD}" ]; then
  echo "${OS_DISTRO}: Failure: TLS private key does not match this certificate."
  exit 1
fi
CERT_MOD=""
KEY_MOD=""
echo "${OS_DISTRO}: TLS certs: OK"


echo "${OS_DISTRO}: Configuring TLS params"
################################################################################
crudini --set ${NOVA_CONFIG_FILE} DEFAULT ssl_cert_file "${NOVA_API_TLS_CERT}"
crudini --set ${NOVA_CONFIG_FILE} DEFAULT ssl_key_file "${NOVA_API_TLS_KEY}"


echo "${OS_DISTRO}: Configuring WSGI params"
################################################################################
crudini --set ${NOVA_CONFIG_FILE} DEFAULT secure_proxy_ssl_header "HTTP_X_FORWARDED_PROTO"
crudini --set ${NOVA_CONFIG_FILE} DEFAULT client_socket_timeout "900"
crudini --set ${NOVA_CONFIG_FILE} DEFAULT max_header_line "16384"
crudini --set ${NOVA_CONFIG_FILE} DEFAULT tcp_keepidle "600"
crudini --set ${NOVA_CONFIG_FILE} DEFAULT wsgi_default_pool_size "1000"
crudini --set ${NOVA_CONFIG_FILE} DEFAULT wsgi_keep_alive "True"
