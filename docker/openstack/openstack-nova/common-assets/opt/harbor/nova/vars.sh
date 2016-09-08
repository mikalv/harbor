#!/bin/bash
: ${NOVA_CONFIG_FILE:="/etc/nova/nova.conf"}
: ${NOVA_APACHE_API_CONFIG_FILE:="/etc/httpd/conf.d/wsgi-nova-api.conf"}

: ${NOVA_MARIADB_SERVICE_PORT:="3312"}
: ${NOVA_MARIADB_SERVICE_HOST_SVC:="${NOVA_API_SERVICE_HOSTNAME}-db.${NOVA_SERVICE_NAMESPACE}.svc.$OS_DOMAIN"}
: ${NOVA_DB_CA:="/run/harbor/auth/user/tls.ca"}
: ${NOVA_DB_KEY:="/run/harbor/auth/user/tls.key"}
: ${NOVA_DB_CERT:="/run/harbor/auth/user/tls.crt"}

: ${NOVA_API_SVC_PORT:="8774"}
: ${NOVA_API_TLS_CA:="/run/harbor/auth/ssl/tls.ca"}
: ${NOVA_API_TLS_KEY:="/run/harbor/auth/ssl/tls.key"}
: ${NOVA_API_TLS_CERT:="/run/harbor/auth/ssl/tls.crt"}

: ${AUTH_NOVA_KEYSTONE_PROJECT:="service"}
: ${AUTH_NOVA_KEYSTONE_PROJECT_DOMAIN:="default"}
: ${AUTH_NOVA_KEYSTONE_PROJECT_USER_ROLE:="admin"}
: ${AUTH_NOVA_KEYSTONE_DOMAIN:="default"}
: ${AUTH_NOVA_KEYSTONE_REGION:="RegionOne"}

: ${AUTH_NEUTRON_KEYSTONE_PROJECT:="service"}
: ${AUTH_NEUTRON_KEYSTONE_PROJECT_DOMAIN:="default"}
: ${AUTH_NEUTRON_KEYSTONE_DOMAIN:="default"}
: ${AUTH_NEUTRON_KEYSTONE_REGION:="RegionOne"}
