#!/bin/bash
: ${DESIGNATE_CONFIG_FILE:="/etc/designate/designate.conf"}

: ${DESIGNATE_MARIADB_SERVICE_PORT:="3315"}
: ${DESIGNATE_MARIADB_SERVICE_HOST_SVC:="${DESIGNATE_API_SERVICE_HOSTNAME}-db.${DESIGNATE_SERVICE_NAMESPACE}.svc.$OS_DOMAIN"}
: ${DESIGNATE_DB_CA:="/run/harbor/auth/user/tls.ca"}
: ${DESIGNATE_DB_KEY:="/run/harbor/auth/user/tls.key"}
: ${DESIGNATE_DB_CERT:="/run/harbor/auth/user/tls.crt"}

: ${DESIGNATE_API_SVC_PORT:="9001"}
: ${DESIGNATE_API_TLS_CA:="/run/harbor/auth/ssl/tls.ca"}
: ${DESIGNATE_API_TLS_KEY:="/run/harbor/auth/ssl/tls.key"}
: ${DESIGNATE_API_TLS_CERT:="/run/harbor/auth/ssl/tls.crt"}

: ${AUTH_DESIGNATE_KEYSTONE_PROJECT:="service"}
: ${AUTH_DESIGNATE_KEYSTONE_PROJECT_DOMAIN:="default"}
: ${AUTH_DESIGNATE_KEYSTONE_PROJECT_USER_ROLE:="admin"}
: ${AUTH_DESIGNATE_KEYSTONE_DOMAIN:="default"}
: ${AUTH_DESIGNATE_KEYSTONE_REGION:="RegionOne"}

: ${DESIGNATE_MDNS_SERVICE_HOST_SVC:="${DESIGNATE_API_SERVICE_HOSTNAME}-mdns.${DESIGNATE_SERVICE_NAMESPACE}.svc.$OS_DOMAIN"}

: ${DESIGNATE_DNS_MARIADB_SERVICE_PORT:="3316"}
: ${DESIGNATE_DNS_MARIADB_SERVICE_HOST_SVC:="${DESIGNATE_API_SERVICE_HOSTNAME}-db-pdns.${DESIGNATE_SERVICE_NAMESPACE}.svc.$OS_DOMAIN"}
: ${DESIGNATE_DNS_SERVICE_HOST_SVC:="${DESIGNATE_API_SERVICE_HOSTNAME}-dns.${DESIGNATE_SERVICE_NAMESPACE}.svc.$OS_DOMAIN"}

: ${DESIGNATE_ADMIN_PROJECT:="designate"}
: ${DESIGNATE_ADMIN_DOMAIN:="designate"}
: ${DESIGNATE_ADMIN_ROLE:="admin"}

: ${DESIGNATE_POOL_ID:="794ccc2c-d751-44fe-b57f-8894c9f5c842"}
: ${DESIGNATE_POOL_NAMESERVERS_ID:="0f66b842-96c2-4189-93fc-1dc95a08b012"}
: ${DESIGNATE_POOL_TARGETS_ID:="f26e0b32-736f-4f0a-831b-039a415c481e"}
