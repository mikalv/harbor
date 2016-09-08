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
echo "${OS_DISTRO}: Testing tls certs"
################################################################################
. /etc/os-container.env
. /opt/harbor/service-hosts.sh
. /opt/harbor/harbor-common.sh
. /opt/harbor/horizon/vars.sh


################################################################################
check_required_vars OS_DOMAIN \
                    API_APACHE_CONFIG_FILE \
                    API_TLS_KEY \
                    API_TLS_CERT \
                    API_TLS_CA


################################################################################
openssl verify -CAfile ${API_TLS_CA} ${API_TLS_CERT}
CERT_MOD="$(openssl x509 -noout -modulus -in ${API_TLS_CERT})"
KEY_MOD="$(openssl rsa -noout -modulus -in ${API_TLS_KEY})"
if ! [ "${CERT_MOD}" = "${KEY_MOD}" ]; then
  echo "${OS_DISTRO}: Failure: TLS private key does not match this certificate."
  exit 1
fi
KEY_MOD=""
CERT_MOD=""
echo "${OS_DISTRO}: TLS certs: OK"
