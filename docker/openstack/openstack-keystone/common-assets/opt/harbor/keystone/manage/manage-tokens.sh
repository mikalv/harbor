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
echo "${OS_DISTRO}: Managing tokens"
################################################################################
. /etc/os-container.env
. /opt/harbor/service-hosts.sh
. /opt/harbor/harbor-common.sh
. /opt/harbor/keystone/vars.sh


################################################################################
check_required_vars KEYSTONE_CONFIG_FILE \
                    KEYSTONE_MARIADB_SERVICE_HOST_SVC \
                    KEYSTONE_MARIADB_SERVICE_PORT \
                    AUTH_KEYSTONE_MARIADB_USER \
                    AUTH_KEYSTONE_MARIADB_PASSWORD \
                    AUTH_KEYSTONE_MARIADB_DATABASE \
                    KEYSTONE_FERNET_KEYS_ROOT


################################################################################
crudini --set ${KEYSTONE_CONFIG_FILE} token provider "fernet"
crudini --set ${KEYSTONE_CONFIG_FILE} token driver "sql"


################################################################################
mkdir -p ${KEYSTONE_FERNET_KEYS_ROOT}
chown -R keystone:keystone ${KEYSTONE_FERNET_KEYS_ROOT}
su -s /bin/sh -c "keystone-manage fernet_setup --keystone-user keystone --keystone-group keystone" keystone


echo "${OS_DISTRO}: Uploading tokens to ${KEYSTONE_MARIADB_SERVICE_HOST_SVC}/${AUTH_KEYSTONE_MARIADB_DATABASE} database"
################################################################################
mysql -h ${KEYSTONE_MARIADB_SERVICE_HOST_SVC} \
      --port ${KEYSTONE_MARIADB_SERVICE_PORT} \
      -u ${AUTH_KEYSTONE_MARIADB_USER} \
      -p"${AUTH_KEYSTONE_MARIADB_PASSWORD}" \
      --ssl-key /run/harbor/auth/user/key \
      --ssl-cert /run/harbor/auth/user/crt \
      --ssl-ca /run/harbor/auth/user/ca \
      --secure-auth \
      ${AUTH_KEYSTONE_MARIADB_DATABASE} <<EOF
DROP TABLE IF EXISTS fernet_keys ;
CREATE TABLE IF NOT EXISTS fernet_keys (
id INT(11) NOT NULL AUTO_INCREMENT,
token_id INT(11) DEFAULT NULL,
token_value LONGBLOB DEFAULT NULL,
PRIMARY KEY (id)
) ENGINE=InnoDB ;
EOF

(
cd ${KEYSTONE_FERNET_KEYS_ROOT}
for KEY in $(ls); do
  TOKEN=$(cat $KEY | base64 )
  mysql -h ${KEYSTONE_MARIADB_SERVICE_HOST_SVC} \
        --port ${KEYSTONE_MARIADB_SERVICE_PORT} \
        -u ${AUTH_KEYSTONE_MARIADB_USER} \
        -p"${AUTH_KEYSTONE_MARIADB_PASSWORD}" \
        --ssl-key /run/harbor/auth/user/key \
        --ssl-cert /run/harbor/auth/user/crt \
        --ssl-ca /run/harbor/auth/user/ca \
        --secure-auth \
        ${AUTH_KEYSTONE_MARIADB_DATABASE} <<EOF
INSERT INTO fernet_keys (token_id, token_value ) VALUES ('$KEY', '$TOKEN');
EOF
done
)
