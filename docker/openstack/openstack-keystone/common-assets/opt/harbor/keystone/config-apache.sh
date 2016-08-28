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
. /opt/harbor/keystone/vars.sh


################################################################################
check_required_vars KEYSTONE_APACHE_CONFIG_FILE \
                    KEYSTONE_APACHE_MELLON_CONFIG_FILE \
                    KEYSTONE_API_SERVICE_HOST \
                    KEYSTONE_API_SERVICE_HOST_SVC \
                    KEYSTONE_API_TLS_CERT \
                    KEYSTONE_API_TLS_KEY \
                    KEYSTONE_API_TLS_CA \
                    KEYSTONE_MELLON_ACTIVE \
                    KEYSTONE_MELLON_SP_METADATA \
                    KEYSTONE_MELLON_SP_TLS_KEY \
                    KEYSTONE_MELLON_SP_TLS_CERT \
                    KEYSTONE_MELLON_IDP_METADATA


################################################################################
sed -i "s|{{ KEYSTONE_API_SERVICE_HOST }}|${KEYSTONE_API_SERVICE_HOST}|g" ${KEYSTONE_APACHE_CONFIG_FILE}
sed -i "s|{{ KEYSTONE_API_SERVICE_HOST_SVC }}|${KEYSTONE_API_SERVICE_HOST_SVC}|g" ${KEYSTONE_APACHE_CONFIG_FILE}


################################################################################
sed -i "s|{{ KEYSTONE_API_TLS_CERT }}|${KEYSTONE_API_TLS_CERT}|g" ${KEYSTONE_APACHE_CONFIG_FILE}
sed -i "s|{{ KEYSTONE_API_TLS_KEY }}|${KEYSTONE_API_TLS_KEY}|g" ${KEYSTONE_APACHE_CONFIG_FILE}
sed -i "s|{{ KEYSTONE_API_TLS_CA }}|${KEYSTONE_API_TLS_CA}|g" ${KEYSTONE_APACHE_CONFIG_FILE}


################################################################################
if [ "${KEYSTONE_MELLON_ACTIVE}" == "True" ] ; then
  echo "${OS_DISTRO}: Enabling Mellon"
  sed -i "s|{{ KEYSTONE_MELLON_CONF }}|Include ${KEYSTONE_APACHE_MELLON_CONFIG_FILE}|g" ${KEYSTONE_APACHE_CONFIG_FILE}
  echo "${OS_DISTRO}: Configuring Mellon"
  sed -i "s|{{ KEYSTONE_MELLON_SP_METADATA }}|${KEYSTONE_MELLON_SP_METADATA}|g" ${KEYSTONE_APACHE_MELLON_CONFIG_FILE}
  sed -i "s|{{ KEYSTONE_MELLON_SP_TLS_KEY }}|${KEYSTONE_MELLON_SP_TLS_KEY}|g" ${KEYSTONE_APACHE_MELLON_CONFIG_FILE}
  sed -i "s|{{ KEYSTONE_MELLON_SP_TLS_CERT }}|${KEYSTONE_MELLON_SP_TLS_CERT}|g" ${KEYSTONE_APACHE_MELLON_CONFIG_FILE}
  sed -i "s|{{ KEYSTONE_MELLON_IDP_METADATA }}|${KEYSTONE_MELLON_IDP_METADATA}|g" ${KEYSTONE_APACHE_MELLON_CONFIG_FILE}
else
  echo "${OS_DISTRO}: Disabling Mellon"
  sed -i "s|{{ KEYSTONE_MELLON_CONF }}||g" ${KEYSTONE_APACHE_CONFIG_FILE}
  KEYSTONE_APACHE_MELLON_MODULE_LOAD_CFG="/etc/httpd/conf.d/auth_mellon.load"
  echo "${OS_DISTRO}: Removing Mellon configs: ${KEYSTONE_APACHE_MELLON_CONFIG_FILE} ${KEYSTONE_APACHE_MELLON_MODULE_LOAD_CFG}"
  rm -f ${KEYSTONE_APACHE_MELLON_CONFIG_FILE}
  rm -f ${KEYSTONE_APACHE_MELLON_MODULE_LOAD_CFG}
fi
