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
echo "${OS_DISTRO}: Configuring apache"
################################################################################
. /etc/os-container.env
. /opt/harbor/service-hosts.sh
. /opt/harbor/harbor-common.sh
. /opt/harbor/ipsilon/vars.sh


################################################################################
check_required_vars APACHE_CONFIG_FILE \
                    APACHE_SSL_CONFIG_FILE \
                    APACHE_RW_CONFIG_FILE \
                    IPSILON_API_SERVICE_PORT \
                    IPSILON_SERVICE_HOST \
                    IPSILON_SERVICE_HOST_SVC \
                    IPSILON_API_TLS_CERT \
                    IPSILON_API_TLS_KEY \
                    IPSILON_API_TLS_CA


################################################################################
sed -i 's|Listen 80|#Listen 80|g' ${APACHE_CONFIG_FILE}
sed -i 's|^ErrorLog \"logs/error_log\"|ErrorLog /dev/stderr|' ${APACHE_CONFIG_FILE}
sed -i 's|CustomLog \"logs/access_log\"|CustomLog /dev/stdout|' ${APACHE_CONFIG_FILE}
sed -i 's|^ErrorLog logs/ssl_error_log|ErrorLog /dev/stderr|' ${APACHE_SSL_CONFIG_FILE}
sed -i 's|^TransferLog logs/ssl_access_log|TransferLog /dev/stdout|' ${APACHE_SSL_CONFIG_FILE}
sed -i 's|^CustomLog logs/ssl_request_log|CustomLog /dev/stdout|' ${APACHE_SSL_CONFIG_FILE}


################################################################################
sed -i "s|{{ IPSILON_API_SERVICE_PORT }}|${IPSILON_API_SERVICE_PORT}|g" ${APACHE_SSL_CONFIG_FILE}


################################################################################
sed -i "s|{{ IPSILON_SERVICE_HOST }}|${IPSILON_SERVICE_HOST}|g" ${APACHE_SSL_CONFIG_FILE}
sed -i "s|{{ IPSILON_SERVICE_HOST_SVC }}|${IPSILON_SERVICE_HOST_SVC}|g" ${APACHE_SSL_CONFIG_FILE}


################################################################################
sed -i "s|{{ IPSILON_API_TLS_CERT }}|${IPSILON_API_TLS_CERT}|g" ${APACHE_SSL_CONFIG_FILE}
sed -i "s|{{ IPSILON_API_TLS_KEY }}|${IPSILON_API_TLS_KEY}|g" ${APACHE_SSL_CONFIG_FILE}
sed -i "s|{{ IPSILON_API_TLS_CA }}|${IPSILON_API_TLS_CA}|g" ${APACHE_SSL_CONFIG_FILE}


################################################################################
sed -i "s|{{ IPSILON_API_TLS_CA }}|${IPSILON_API_TLS_CA}|g" ${APACHE_SSL_CONFIG_FILE}


################################################################################
sed -i "s|{{ IPSILON_SERVICE_HOST }}|${IPSILON_SERVICE_HOST}|g" ${APACHE_RW_CONFIG_FILE}
sed -i "s|^</VirtualHost>|Include ${APACHE_RW_CONFIG_FILE}\n</VirtualHost>|g" ${APACHE_SSL_CONFIG_FILE}
