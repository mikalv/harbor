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
echo "${OS_DISTRO}: Configuring secret-store"
################################################################################
. /etc/os-container.env
. /opt/harbor/service-hosts.sh
. /opt/harbor/harbor-common.sh
. /opt/harbor/barbican/vars.sh


################################################################################
check_required_vars BARBICAN_CONFIG_FILE \
                    OS_DOMAIN \
                    FREEIPA_SERVICE_HOST \
                    DOGTAG_PLUGIN_ROOT \
                    DOGTAG_KRA_AGENT_PEM \
                    FREEIPA_DOGTAG_PORT \
                    SNAKEOIL_PLUGIN_ROOT


echo "${OS_DISTRO}: dogtag"
################################################################################
crudini --set ${BARBICAN_CONFIG_FILE} secretstore enabled_secretstore_plugins "dogtag_crypto"
crudini --set ${BARBICAN_CONFIG_FILE} dogtag_plugin dogtag_host "${FREEIPA_SERVICE_HOST}"
crudini --set ${BARBICAN_CONFIG_FILE} dogtag_plugin dogtag_port "${FREEIPA_DOGTAG_PORT}"
crudini --set ${BARBICAN_CONFIG_FILE} dogtag_plugin pem_path "${DOGTAG_KRA_AGENT_PEM}"
crudini --del --list ${BARBICAN_CONFIG_FILE} certificate enabled_certificate_plugins
crudini --set ${BARBICAN_CONFIG_FILE} certificate enabled_certificate_plugins "dogtag"
crudini --set ${BARBICAN_CONFIG_FILE} dogtag_plugin nss_db_path "${DOGTAG_PLUGIN_ROOT}/alias"
crudini --set ${BARBICAN_CONFIG_FILE} dogtag_plugin nss_db_path_ca "${DOGTAG_PLUGIN_ROOT}/alias-ca"
crudini --set ${BARBICAN_CONFIG_FILE} dogtag_plugin nss_password "password123"
crudini --set ${BARBICAN_CONFIG_FILE} dogtag_plugin simple_cmc_profile "caOtherCert"
crudini --set ${BARBICAN_CONFIG_FILE} dogtag_plugin ca_expiration_time "1"
crudini --set ${BARBICAN_CONFIG_FILE} dogtag_plugin plugin_working_dir "${DOGTAG_PLUGIN_ROOT}/working"
crudini --set ${BARBICAN_CONFIG_FILE} dogtag_plugin plugin_name "FreeIPA Dogtag KRA"


echo "${OS_DISTRO}: snakeoil_ca_plugin"
################################################################################
crudini --set ${BARBICAN_CONFIG_FILE} snakeoil_ca_plugin ca_cert_path "${SNAKEOIL_PLUGIN_ROOT}/snakeoil-ca.crt"
crudini --set ${BARBICAN_CONFIG_FILE} snakeoil_ca_plugin ca_cert_key_path "${SNAKEOIL_PLUGIN_ROOT}/snakeoil-ca.key"
crudini --set ${BARBICAN_CONFIG_FILE} snakeoil_ca_plugin ca_cert_chain_path "${SNAKEOIL_PLUGIN_ROOT}/snakeoil-ca.chain"
crudini --set ${BARBICAN_CONFIG_FILE} snakeoil_ca_plugin ca_cert_pkcs7_path "${SNAKEOIL_PLUGIN_ROOT}/snakeoil-ca.p7b"
crudini --set ${BARBICAN_CONFIG_FILE} snakeoil_ca_plugin subca_cert_key_directory "${SNAKEOIL_PLUGIN_ROOT}/snakeoil-cas"
