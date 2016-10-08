#!/bin/bash
: ${BARBICAN_CONFIG_FILE:="/etc/barbican/barbican.conf"}
: ${BARBICAN_PASTE_CONFIG_FILE:="/etc/barbican/barbican-api-paste.ini"}
: ${BARBICAN_VASSALS_CONFIG_FILE:="/etc/barbican/vassals/barbican-api.ini"}

: ${BARBICAN_MARIADB_SERVICE_PORT:="3317"}
: ${BARBICAN_MARIADB_SERVICE_HOST_SVC:="${BARBICAN_API_SERVICE_HOSTNAME}-db.${BARBICAN_SERVICE_NAMESPACE}.svc.$OS_DOMAIN"}
: ${BARBICAN_DB_CA:="/run/harbor/auth/user/tls.ca"}
: ${BARBICAN_DB_KEY:="/run/harbor/auth/user/tls.key"}
: ${BARBICAN_DB_CERT:="/run/harbor/auth/user/tls.crt"}

: ${BARBICAN_API_SVC_PORT:="9311"}
: ${BARBICAN_API_TLS_CA:="/run/harbor/auth/ssl/tls.ca"}
: ${BARBICAN_API_TLS_KEY:="/run/harbor/auth/ssl/tls.key"}
: ${BARBICAN_API_TLS_CERT:="/run/harbor/auth/ssl/tls.crt"}

: ${AUTH_BARBICAN_KEYSTONE_PROJECT:="service"}
: ${AUTH_BARBICAN_KEYSTONE_PROJECT_DOMAIN:="default"}
: ${AUTH_BARBICAN_KEYSTONE_PROJECT_USER_ROLE:="admin"}
: ${AUTH_BARBICAN_KEYSTONE_DOMAIN:="default"}
: ${AUTH_BARBICAN_KEYSTONE_REGION:="RegionOne"}


: ${AUTH_BARBICAN_KEYSTONE_SERVICE_PROJECT:="service"}
: ${AUTH_BARBICAN_KEYSTONE_SERVICE_PROJECT_DOMAIN:="default"}
: ${AUTH_BARBICAN_KEYSTONE_SERVICE_PROJECT_USER_ROLE:="key-manager:service-admin"}
: ${AUTH_BARBICAN_KEYSTONE_SERVICE_DOMAIN:="default"}
: ${AUTH_BARBICAN_KEYSTONE_SERVICE_REGION:="RegionOne"}
