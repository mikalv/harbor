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
echo "${OS_DISTRO}: Configuring tokens"
################################################################################
. /etc/os-container.env
. /opt/harbor/service-hosts.sh
. /opt/harbor/harbor-common.sh
. /opt/harbor/keystone/vars.sh


################################################################################
check_required_vars KEYSTONE_CONFIG_FILE \
                    OS_DOMAIN \
                    KEYSTONE_MARIADB_SERVICE_HOST_SVC \
                    KEYSTONE_MARIADB_SERVICE_PORT \
                    AUTH_KEYSTONE_MARIADB_USER \
                    AUTH_KEYSTONE_MARIADB_PASSWORD \
                    AUTH_KEYSTONE_MARIADB_DATABASE \
                    KEYSTONE_FERNET_KEYS_ROOT


################################################################################
crudini --set ${KEYSTONE_CONFIG_FILE} token provider "fernet"
crudini --set ${KEYSTONE_CONFIG_FILE} token driver "sql"


echo "${OS_DISTRO}: Downloading tokens from ${KEYSTONE_MARIADB_SERVICE_HOST_SVC}/${AUTH_KEYSTONE_MARIADB_DATABASE} database"
################################################################################
mkdir -p ${KEYSTONE_FERNET_KEYS_ROOT}
echo "SELECT * FROM fernet_keys;" | mysql -h ${KEYSTONE_MARIADB_SERVICE_HOST_SVC} \
    --port ${KEYSTONE_MARIADB_SERVICE_PORT} \
    -u ${AUTH_KEYSTONE_MARIADB_USER} \
    -p"${AUTH_KEYSTONE_MARIADB_PASSWORD}" \
    --ssl-key /run/harbor/auth/user/tls.key \
    --ssl-cert /run/harbor/auth/user/tls.crt \
    --ssl-ca /run/harbor/auth/user/tls.ca \
    --secure-auth \
    ${AUTH_KEYSTONE_MARIADB_DATABASE} > ${KEYSTONE_FERNET_KEYS_ROOT}/fernet_keys


echo "${OS_DISTRO}: Unpacking tokens"
################################################################################
IFS='
'
for FERNET_KEY in $( cat ${KEYSTONE_FERNET_KEYS_ROOT}/fernet_keys | sed '1d' | awk '{$1="";  sub("  ", " "); print}'); do
  TOKEN_ID=$(echo $FERNET_KEY | awk '{ print $1 }')
  TOKEN_VALUE=$(echo $FERNET_KEY | awk '{ print $2 }' | base64 -d)
  echo "$TOKEN_VALUE" > ${KEYSTONE_FERNET_KEYS_ROOT}/$TOKEN_ID
done
unset IFS
rm -f ${KEYSTONE_FERNET_KEYS_ROOT}/fernet_keys


echo "${OS_DISTRO}: Fixing token permissions"
################################################################################
chown -R keystone:keystone ${KEYSTONE_FERNET_KEYS_ROOT}
