#!/bin/bash
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
(IFS='
'
for FERNET_KEY in $( (mysql -h ${KEYSTONE_MARIADB_SERVICE_HOST_SVC} \
      --port ${KEYSTONE_MARIADB_SERVICE_PORT} \
      -u ${AUTH_KEYSTONE_MARIADB_USER} \
      -p"${AUTH_KEYSTONE_MARIADB_PASSWORD}" \
      --ssl-key /run/harbor/auth/user/key \
      --ssl-cert /run/harbor/auth/user/crt \
      --ssl-ca /run/harbor/auth/user/ca \
      --secure-auth \
      ${AUTH_KEYSTONE_MARIADB_DATABASE} <<EOF
SELECT * FROM fernet_keys;
EOF
) | sed '1d' | awk '{$1="";  sub("  ", " "); print}'); do (
  TOKEN_ID=$(echo $FERNET_KEY | awk '{ print $1 }')
  TOKEN_VALUE=$(echo $FERNET_KEY | awk '{ print $2 }' | base64 -d)
  echo "$TOKEN_VALUE" > ${KEYSTONE_FERNET_KEYS_ROOT}/$TOKEN_ID )
done)

chown -R keystone:keystone ${KEYSTONE_FERNET_KEYS_ROOT}
