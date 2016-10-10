#!/bin/bash
: ${MISTRAL_CONFIG_FILE:="/etc/mistral/mistral.conf"}

: ${MISTRAL_MARIADB_SERVICE_PORT:="3319"}
: ${MISTRAL_MARIADB_SERVICE_HOST_SVC:="${MISTRAL_API_SERVICE_HOSTNAME}-db.${MISTRAL_SERVICE_NAMESPACE}.svc.$OS_DOMAIN"}
: ${MISTRAL_DB_CA:="/run/harbor/auth/user/tls.ca"}
: ${MISTRAL_DB_KEY:="/run/harbor/auth/user/tls.key"}
: ${MISTRAL_DB_CERT:="/run/harbor/auth/user/tls.crt"}

: ${MISTRAL_API_SVC_PORT:="8989"}
: ${MISTRAL_API_TLS_CA:="/run/harbor/auth/ssl/tls.ca"}
: ${MISTRAL_API_TLS_KEY:="/run/harbor/auth/ssl/tls.key"}
: ${MISTRAL_API_TLS_CERT:="/run/harbor/auth/ssl/tls.crt"}

: ${AUTH_MISTRAL_KEYSTONE_PROJECT:="service"}
: ${AUTH_MISTRAL_KEYSTONE_PROJECT_DOMAIN:="default"}
: ${AUTH_MISTRAL_KEYSTONE_PROJECT_USER_ROLE:="admin"}
: ${AUTH_MISTRAL_KEYSTONE_DOMAIN:="default"}
: ${AUTH_MISTRAL_KEYSTONE_REGION:="RegionOne"}
