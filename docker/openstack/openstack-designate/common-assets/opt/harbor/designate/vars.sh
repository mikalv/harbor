#!/bin/bash
: ${DESIGNATE_CONFIG_FILE:="/etc/designate/designate.conf"}

: ${DESIGNATE_MARIADB_SERVICE_PORT:="3315"}
: ${DESIGNATE_MARIADB_SERVICE_HOST_SVC:="${DESIGNATE_API_SERVICE_HOSTNAME}-db.${DESIGNATE_SERVICE_NAMESPACE}.svc.$OS_DOMAIN"}
: ${DESIGNATE_DB_CA:="/run/harbor/auth/user/tls.ca"}
: ${DESIGNATE_DB_KEY:="/run/harbor/auth/user/tls.key"}
: ${DESIGNATE_DB_CERT:="/run/harbor/auth/user/tls.crt"}

: ${DESIGNATE_API_SVC_PORT:="8082"}
: ${DESIGNATE_API_TLS_CA:="/run/harbor/auth/ssl/tls.ca"}
: ${DESIGNATE_API_TLS_KEY:="/run/harbor/auth/ssl/tls.key"}
: ${DESIGNATE_API_TLS_CERT:="/run/harbor/auth/ssl/tls.crt"}

: ${AUTH_DESIGNATE_KEYSTONE_PROJECT:="service"}
: ${AUTH_DESIGNATE_KEYSTONE_PROJECT_DOMAIN:="default"}
: ${AUTH_DESIGNATE_KEYSTONE_PROJECT_USER_ROLE:="admin"}
: ${AUTH_DESIGNATE_KEYSTONE_DOMAIN:="default"}
: ${AUTH_DESIGNATE_KEYSTONE_REGION:="RegionOne"}
