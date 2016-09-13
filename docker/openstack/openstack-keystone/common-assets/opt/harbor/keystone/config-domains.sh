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
echo "${OS_DISTRO}: Configuring domains"
################################################################################
. /etc/os-container.env
. /opt/harbor/service-hosts.sh
. /opt/harbor/harbor-common.sh
. /opt/harbor/keystone/vars.sh


################################################################################
check_required_vars KEYSTONE_CONFIG_FILE \
                    OS_DOMAIN \
                    FREEIPA_SERVICE_HOST \
                    AUTH_KEYSTONE_LDAP_USER \
                    AUTH_KEYSTONE_LDAP_PASSWORD \
                    KEYSTONE_LDAP_BASE_DN

echo "${OS_DISTRO}: Enabling domain specific drivers"
################################################################################
crudini --set ${KEYSTONE_CONFIG_FILE} identity domain_specific_drivers_enabled "true"
crudini --set ${KEYSTONE_CONFIG_FILE} identity domain_configurations_from_database "true"


echo "${OS_DISTRO}: Testing LDAP"
################################################################################
ldapsearch \
    -h ${FREEIPA_SERVICE_HOST} -p 389 -x -u \
    -D "uid=${AUTH_KEYSTONE_LDAP_USER},cn=users,cn=accounts,${KEYSTONE_LDAP_BASE_DN}" \
    -w "${AUTH_KEYSTONE_LDAP_PASSWORD}" \
    -b "cn=users,cn=accounts,${KEYSTONE_LDAP_BASE_DN}" \
    "uid=${AUTH_KEYSTONE_LDAP_USER}"
