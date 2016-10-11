#!/bin/bash
: ${GNOCCHI_CONFIG_FILE:="/etc/gnocchi/gnocchi.conf"}

: ${GNOCCHI_MARIADB_SERVICE_PORT:="3320"}
: ${GNOCCHI_MARIADB_SERVICE_HOST_SVC:="${GNOCCHI_API_SERVICE_HOSTNAME}-db.${GNOCCHI_SERVICE_NAMESPACE}.svc.$OS_DOMAIN"}
: ${GNOCCHI_DB_CA:="/run/harbor/auth/user/tls.ca"}
: ${GNOCCHI_DB_KEY:="/run/harbor/auth/user/tls.key"}
: ${GNOCCHI_DB_CERT:="/run/harbor/auth/user/tls.crt"}

: ${GNOCCHI_API_SVC_PORT:="8041"}
: ${GNOCCHI_API_TLS_CA:="/run/harbor/auth/ssl/tls.ca"}
: ${GNOCCHI_API_TLS_KEY:="/run/harbor/auth/ssl/tls.key"}
: ${GNOCCHI_API_TLS_CERT:="/run/harbor/auth/ssl/tls.crt"}

: ${AUTH_GNOCCHI_KEYSTONE_PROJECT:="service"}
: ${AUTH_GNOCCHI_KEYSTONE_PROJECT_DOMAIN:="default"}
: ${AUTH_GNOCCHI_KEYSTONE_PROJECT_USER_ROLE:="admin"}
: ${AUTH_GNOCCHI_KEYSTONE_DOMAIN:="default"}
: ${AUTH_GNOCCHI_KEYSTONE_REGION:="RegionOne"}
