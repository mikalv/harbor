#!/bin/sh
set -e
: ${CFG_SECTION:="keystone_authtoken"}
echo "Configuring $cfg ${CFG_SECTION}"

set -x
check_required_vars cfg KEYSTONE_ADMIN_SERVICE_HOST \
                        KEYSTONE_USER \
                        SERVICE_TENANT_NAME \
                        KEYSTONE_PASSWORD \
                        DEFAULT_REGION \
                        CFG_SECTION

crudini --set $cfg ${CFG_SECTION} auth_plugin "password"
crudini --set $cfg ${CFG_SECTION} auth_url "${KEYSTONE_AUTH_PROTOCOL}://${KEYSTONE_ADMIN_SERVICE_HOST}:35357/"
crudini --set $cfg ${CFG_SECTION} auth_version "v3"
crudini --set $cfg ${CFG_SECTION} project_name "${SERVICE_TENANT_NAME}"
crudini --set $cfg ${CFG_SECTION} user_domain_name "Default"
crudini --set $cfg ${CFG_SECTION} project_domain_name "Default"
crudini --set $cfg ${CFG_SECTION} username "${KEYSTONE_USER}"
crudini --set $cfg ${CFG_SECTION} password "${KEYSTONE_PASSWORD}"
