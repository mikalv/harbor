#!/bin/bash

# Copyright 2016 Port Direct
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -e
echo "${OS_DISTRO}: TLS Config"
################################################################################
. /etc/os-container.env
. /opt/harbor/service-hosts.sh
. /opt/harbor/harbor-common.sh
. /opt/harbor/elasticsearch/vars.sh


################################################################################
check_required_vars ELS_CONFIG_DIR \
                    OS_DOMAIN \
                    CEILOMETER_ELS_CERT \
                    CEILOMETER_ELS_KEY \
                    CEILOMETER_ELS_CA \
                    CEILOMETER_ELS_SERVICE_HOST_SVC


################################################################################
cat ${CEILOMETER_ELS_CERT} > /usr/share/elasticsearch/config/tls.crt
cat ${CEILOMETER_ELS_KEY} > /usr/share/elasticsearch/config/tls.key
cat ${CEILOMETER_ELS_CA} > /usr/share/elasticsearch/config/tls.ca

# mkdir -p ${ELS_CONFIG_DIR}/scripts
# echo $(uuidgen) > ${ELS_CONFIG_DIR}/.pkcs12-storepass
# openssl pkcs12 \
# -export \
# -in ${CEILOMETER_ELS_CERT} \
# -inkey ${CEILOMETER_ELS_KEY} \
# -out ${ELS_CONFIG_DIR}/${CEILOMETER_ELS_SERVICE_HOST_SVC}.p12 \
# -name ${CEILOMETER_ELS_SERVICE_HOST_SVC} \
# -CAfile ${CEILOMETER_ELS_CA} \
# -caname root \
# -passout file:${ELS_CONFIG_DIR}/.pkcs12-storepass
#
# echo $(uuidgen) > ${ELS_CONFIG_DIR}/.tls-storepass
# echo $(uuidgen) > ${ELS_CONFIG_DIR}/.tls-keypass
# keytool -importkeystore \
#         -deststorepass $(cat ${ELS_CONFIG_DIR}/.tls-storepass) \
#         -destkeypass $(cat ${ELS_CONFIG_DIR}/.tls-keypass) \
#         -destkeystore ${ELS_CONFIG_DIR}/${CEILOMETER_ELS_SERVICE_HOST_SVC}.keystore \
#         -srckeystore ${ELS_CONFIG_DIR}/${CEILOMETER_ELS_SERVICE_HOST_SVC}.p12 \
#         -srcstoretype PKCS12 \
#         -srcstorepass  $(cat ${ELS_CONFIG_DIR}/.pkcs12-storepass) \
#         -alias ${CEILOMETER_ELS_SERVICE_HOST_SVC}
# rm -rfv ${ELS_CONFIG_DIR}/${CEILOMETER_ELS_SERVICE_HOST_SVC}.p12 ${ELS_CONFIG_DIR}/.pkcs12-storepass
