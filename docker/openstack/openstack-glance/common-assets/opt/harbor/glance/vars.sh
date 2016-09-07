#!/bin/bash
: ${GLANCE_CONFIG_FILE:="/etc/glance/glance.conf"}

: ${GLANCE_MARIADB_SERVICE_PORT:="3310"}
: ${GLANCE_MARIADB_SERVICE_HOST_SVC:="${GLANCE_API_SERVICE_HOSTNAME}-db.${GLANCE_SERVICE_NAMESPACE}.svc.$OS_DOMAIN"}
: ${GLANCE_DB_CA:="/run/harbor/auth/user/tls.ca"}
: ${GLANCE_DB_KEY:="/run/harbor/auth/user/tls.key"}
: ${GLANCE_DB_CERT:="/run/harbor/auth/user/tls.crt"}

: ${GLANCE_API_SVC_PORT:="9292"}
: ${GLANCE_API_TLS_CA:="/run/harbor/auth/ssl/tls.ca"}
: ${GLANCE_API_TLS_KEY:="/run/harbor/auth/ssl/tls.key"}
: ${GLANCE_API_TLS_CERT:="/run/harbor/auth/ssl/tls.crt"}

: ${GLANCE_REGISTRY_SVC_PORT:="9191"}
: ${GLANCE_REGISTRY_TLS_CA:="/run/harbor/auth/ssl/tls.ca"}
: ${GLANCE_REGISTRY_TLS_KEY:="/run/harbor/auth/ssl/tls.key"}
: ${GLANCE_REGISTRY_TLS_CERT:="/run/harbor/auth/ssl/tls.crt"}

: ${AUTH_GLANCE_KEYSTONE_PROJECT:="service"}
: ${AUTH_GLANCE_KEYSTONE_PROJECT_DOMAIN:="default"}
: ${AUTH_GLANCE_KEYSTONE_PROJECT_USER_ROLE:="admin"}
: ${AUTH_GLANCE_KEYSTONE_DOMAIN:="default"}
: ${AUTH_GLANCE_KEYSTONE_REGION:="RegionOne"}

: ${AUTH_NOVA_KEYSTONE_PROJECT:="service"}
: ${AUTH_NOVA_KEYSTONE_PROJECT_DOMAIN:="default"}
: ${AUTH_NOVA_KEYSTONE_DOMAIN:="default"}
: ${AUTH_NOVA_KEYSTONE_REGION:="RegionOne"}
