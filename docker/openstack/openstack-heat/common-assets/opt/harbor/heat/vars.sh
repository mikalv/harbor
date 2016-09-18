#!/bin/bash
: ${HEAT_CONFIG_FILE:="/etc/heat/heat.conf"}

: ${HEAT_MARIADB_SERVICE_PORT:="3313"}
: ${HEAT_MARIADB_SERVICE_HOST_SVC:="${HEAT_API_SERVICE_HOSTNAME}-db.${HEAT_SERVICE_NAMESPACE}.svc.$OS_DOMAIN"}
: ${HEAT_DB_CA:="/run/harbor/auth/user/tls.ca"}
: ${HEAT_DB_KEY:="/run/harbor/auth/user/tls.key"}
: ${HEAT_DB_CERT:="/run/harbor/auth/user/tls.crt"}

: ${HEAT_API_SVC_PORT:="8004"}
: ${HEAT_API_TLS_CA:="/run/harbor/auth/ssl/tls.ca"}
: ${HEAT_API_TLS_KEY:="/run/harbor/auth/ssl/tls.key"}
: ${HEAT_API_TLS_CERT:="/run/harbor/auth/ssl/tls.crt"}

: ${HEAT_API_CFN_SVC_PORT:="8000"}
: ${HEAT_API_CFN_TLS_CA:="/run/harbor/auth/ssl/tls.ca"}
: ${HEAT_API_CFN_TLS_KEY:="/run/harbor/auth/ssl/tls.key"}
: ${HEAT_API_CFN_TLS_CERT:="/run/harbor/auth/ssl/tls.crt"}

: ${HEAT_API_CLOUDWATCH_SVC_PORT:="8003"}
: ${HEAT_API_CLOUDWATCH_TLS_CA:="/run/harbor/auth/ssl/tls.ca"}
: ${HEAT_API_CLOUDWATCH_TLS_KEY:="/run/harbor/auth/ssl/tls.key"}
: ${HEAT_API_CLOUDWATCH_TLS_CERT:="/run/harbor/auth/ssl/tls.crt"}

: ${AUTH_HEAT_KEYSTONE_PROJECT:="service"}
: ${AUTH_HEAT_KEYSTONE_PROJECT_DOMAIN:="default"}
: ${AUTH_HEAT_KEYSTONE_PROJECT_USER_ROLE:="admin"}
: ${AUTH_HEAT_KEYSTONE_DOMAIN:="default"}
: ${AUTH_HEAT_KEYSTONE_REGION:="RegionOne"}

: ${AUTH_HEAT_KEYSTONE_TRUST_PROJECT:="service"}
: ${AUTH_HEAT_KEYSTONE_TRUST_PROJECT_DOMAIN:="default"}
: ${AUTH_HEAT_KEYSTONE_TRUST_PROJECT_USER_ROLE:="admin"}
: ${AUTH_HEAT_KEYSTONE_TRUST_DOMAIN:="default"}
: ${AUTH_HEAT_KEYSTONE_TRUST_REGION:="RegionOne"}


: ${AUTH_HEAT_KEYSTONE_DOMAIN_DOMAIN_ADMIN_ROLE:="admin"}
: ${AUTH_HEAT_KEYSTONE_DOMAIN_DOMAIN:="heat"}
: ${AUTH_HEAT_KEYSTONE_DOMAIN_REGION:="RegionOne"}
