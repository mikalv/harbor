#!/bin/bash
: ${CINDER_CONFIG_FILE:="/etc/cinder/cinder.conf"}

: ${CINDER_MARIADB_SERVICE_PORT:="3311"}
: ${CINDER_MARIADB_SERVICE_HOST_SVC:="${CINDER_API_SERVICE_HOSTNAME}-db.${CINDER_SERVICE_NAMESPACE}.svc.$OS_DOMAIN"}
: ${CINDER_DB_CA:="/run/harbor/auth/user/tls.ca"}
: ${CINDER_DB_KEY:="/run/harbor/auth/user/tls.key"}
: ${CINDER_DB_CERT:="/run/harbor/auth/user/tls.crt"}

: ${CINDER_API_SVC_PORT:="8776"}
: ${CINDER_API_TLS_CA:="/run/harbor/auth/ssl/tls.ca"}
: ${CINDER_API_TLS_KEY:="/run/harbor/auth/ssl/tls.key"}
: ${CINDER_API_TLS_CERT:="/run/harbor/auth/ssl/tls.crt"}

: ${AUTH_CINDER_KEYSTONE_PROJECT:="service"}
: ${AUTH_CINDER_KEYSTONE_PROJECT_DOMAIN:="default"}
: ${AUTH_CINDER_KEYSTONE_PROJECT_USER_ROLE:="admin"}
: ${AUTH_CINDER_KEYSTONE_DOMAIN:="default"}
: ${AUTH_CINDER_KEYSTONE_REGION:="RegionOne"}

: ${AUTH_NOVA_KEYSTONE_PROJECT:="service"}
: ${AUTH_NOVA_KEYSTONE_PROJECT_DOMAIN:="default"}
: ${AUTH_NOVA_KEYSTONE_DOMAIN:="default"}
: ${AUTH_NOVA_KEYSTONE_REGION:="RegionOne"}
