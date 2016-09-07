#!/bin/bash
: ${HEAT_CONFIG_FILE:="/etc/nova/nova.conf"}

: ${HEAT_MARIADB_SERVICE_PORT:="3312"}
: ${HEAT_MARIADB_SERVICE_HOST_SVC:="${HEAT_API_SERVICE_HOSTNAME}-db.${HEAT_SERVICE_NAMESPACE}.svc.$OS_DOMAIN"}
: ${HEAT_DB_CA:="/run/harbor/auth/user/tls.ca"}
: ${HEAT_DB_KEY:="/run/harbor/auth/user/tls.key"}
: ${HEAT_DB_CERT:="/run/harbor/auth/user/tls.crt"}

: ${HEAT_API_SVC_PORT:="8774"}
: ${HEAT_API_TLS_CA:="/run/harbor/auth/ssl/tls.ca"}
: ${HEAT_API_TLS_KEY:="/run/harbor/auth/ssl/tls.key"}
: ${HEAT_API_TLS_CERT:="/run/harbor/auth/ssl/tls.crt"}

: ${AUTH_HEAT_KEYSTONE_PROJECT:="service"}
: ${AUTH_HEAT_KEYSTONE_PROJECT_DOMAIN:="default"}
: ${AUTH_HEAT_KEYSTONE_PROJECT_USER_ROLE:="admin"}
: ${AUTH_HEAT_KEYSTONE_DOMAIN:="default"}
: ${AUTH_HEAT_KEYSTONE_REGION:="RegionOne"}

: ${AUTH_NEUTRON_KEYSTONE_PROJECT:="service"}
: ${AUTH_NEUTRON_KEYSTONE_PROJECT_DOMAIN:="default"}
: ${AUTH_NEUTRON_KEYSTONE_DOMAIN:="default"}
: ${AUTH_NEUTRON_KEYSTONE_REGION:="RegionOne"}
