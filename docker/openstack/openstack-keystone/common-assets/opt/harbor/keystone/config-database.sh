#!/bin/bash
set -e
echo "${OS_DISTRO}: Configuring database connection"
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
                    KEYSTONE_DB_CA \
                    KEYSTONE_DB_KEY \
                    KEYSTONE_DB_CERT \
                    AUTH_KEYSTONE_DB_USER \
                    AUTH_KEYSTONE_DB_PASSWORD \
                    AUTH_KEYSTONE_DB_NAME


################################################################################
crudini --set ${KEYSTONE_CONFIG_FILE} database connection \
"mysql+pymysql://${AUTH_KEYSTONE_DB_USER}:${AUTH_KEYSTONE_DB_PASSWORD}@${KEYSTONE_MARIADB_SERVICE_HOST_SVC}:${KEYSTONE_MARIADB_SERVICE_PORT}/${AUTH_KEYSTONE_DB_NAME}?charset=utf8&ssl_ca=${KEYSTONE_DB_CA}&ssl_key=${KEYSTONE_DB_KEY}&ssl_cert=${KEYSTONE_DB_CERT}&ssl_verify_cert"
