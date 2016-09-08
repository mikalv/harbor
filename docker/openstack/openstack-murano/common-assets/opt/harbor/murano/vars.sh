#!/bin/bash
: ${MURANO_CONFIG_FILE:="/etc/murano/murano.conf"}

: ${MURANO_MARIADB_SERVICE_PORT:="3314"}
: ${MURANO_MARIADB_SERVICE_HOST_SVC:="${MURANO_API_SERVICE_HOSTNAME}-db.${MURANO_SERVICE_NAMESPACE}.svc.$OS_DOMAIN"}
: ${MURANO_DB_CA:="/run/harbor/auth/user/tls.ca"}
: ${MURANO_DB_KEY:="/run/harbor/auth/user/tls.key"}
: ${MURANO_DB_CERT:="/run/harbor/auth/user/tls.crt"}

: ${MURANO_API_SVC_PORT:="8082"}
: ${MURANO_API_TLS_CA:="/run/harbor/auth/ssl/tls.ca"}
: ${MURANO_API_TLS_KEY:="/run/harbor/auth/ssl/tls.key"}
: ${MURANO_API_TLS_CERT:="/run/harbor/auth/ssl/tls.crt"}

: ${AUTH_MURANO_KEYSTONE_PROJECT:="service"}
: ${AUTH_MURANO_KEYSTONE_PROJECT_DOMAIN:="default"}
: ${AUTH_MURANO_KEYSTONE_PROJECT_USER_ROLE:="admin"}
: ${AUTH_MURANO_KEYSTONE_DOMAIN:="default"}
: ${AUTH_MURANO_KEYSTONE_REGION:="RegionOne"}

: ${MURANO_RABBITMQ_SERVICE_PORT:="5673"}
: ${MURANO_RABBITMQ_SERVICE_HOST_SVC:="${MURANO_API_SERVICE_HOSTNAME}-ampq.${MURANO_SERVICE_NAMESPACE}.svc.$OS_DOMAIN"}
