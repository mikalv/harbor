#!/bin/bash
: ${MAGNUM_CONFIG_FILE:="/etc/magnum/magnum.conf"}

: ${MAGNUM_MARIADB_SERVICE_PORT:="3318"}
: ${MAGNUM_MARIADB_SERVICE_HOST_SVC:="${MAGNUM_API_SERVICE_HOSTNAME}-db.${MAGNUM_SERVICE_NAMESPACE}.svc.$OS_DOMAIN"}
: ${MAGNUM_DB_CA:="/run/harbor/auth/user/tls.ca"}
: ${MAGNUM_DB_KEY:="/run/harbor/auth/user/tls.key"}
: ${MAGNUM_DB_CERT:="/run/harbor/auth/user/tls.crt"}

: ${MAGNUM_API_SVC_PORT:="9511"}
: ${MAGNUM_API_TLS_CA:="/run/harbor/auth/ssl/tls.ca"}
: ${MAGNUM_API_TLS_KEY:="/run/harbor/auth/ssl/tls.key"}
: ${MAGNUM_API_TLS_CERT:="/run/harbor/auth/ssl/tls.crt"}

: ${AUTH_MAGNUM_KEYSTONE_PROJECT:="service"}
: ${AUTH_MAGNUM_KEYSTONE_PROJECT_DOMAIN:="default"}
: ${AUTH_MAGNUM_KEYSTONE_PROJECT_USER_ROLE:="admin"}
: ${AUTH_MAGNUM_KEYSTONE_DOMAIN:="default"}
: ${AUTH_MAGNUM_KEYSTONE_REGION:="RegionOne"}


: ${AUTH_MAGNUM_KEYSTONE_TRUSTEE_PROJECT:="service"}
: ${AUTH_MAGNUM_KEYSTONE_TRUSTEE_PROJECT_DOMAIN:="magnum"}
: ${AUTH_MAGNUM_KEYSTONE_TRUSTEE_PROJECT_USER_ROLE:="admin"}
: ${AUTH_MAGNUM_KEYSTONE_TRUSTEE_DOMAIN:="magnum"}
: ${AUTH_MAGNUM_KEYSTONE_TRUSTEE_REGION:="RegionOne"}
