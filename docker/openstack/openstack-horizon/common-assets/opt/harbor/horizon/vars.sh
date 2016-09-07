#!/bin/bash

OS_COMPONENT=api

: ${API_CONFIG_FILE:="/opt/stack/horizon/openstack_dashboard/local/local_settings.py"}
: ${API_CONFIG_FILE_TEMPLATE:="/opt/harbor/horizon/config/local_settings.py"}

: ${API_APACHE_CONFIG_FILE:="/etc/httpd/conf.d/horizon.conf"}


: ${HORIZON_API_SERVICE_PORT:="4433"}

: ${API_MARIADB_SERVICE_PORT:="3309"}
: ${API_DB_CA:="/run/harbor/auth/user/tls.ca"}
: ${API_DB_KEY:="/run/harbor/auth/user/tls.key"}
: ${API_DB_CERT:="/run/harbor/auth/user/tls.crt"}
: ${API_MARIADB_SERVICE_HOST_SVC:="${HORIZON_API_SERVICE_HOSTNAME}-db.${HORIZON_SERVICE_NAMESPACE}.svc.$OS_DOMAIN"}


: ${API_TLS_CA:="/run/harbor/auth/ssl/tls.ca"}
: ${API_TLS_KEY:="/run/harbor/auth/ssl/tls.key"}
: ${API_TLS_CERT:="/run/harbor/auth/ssl/tls.crt"}



: ${MARIADB_TEST_HOST:="${API_MARIADB_SERVICE_HOST_SVC}"}
: ${MARIADB_TEST_PORT:="${API_MARIADB_SERVICE_PORT}"}
: ${MARIADB_TEST_USER:="${AUTH_API_MARIADB_USER}"}
: ${MARIADB_TEST_PASSWORD:="${AUTH_API_MARIADB_PASSWORD}"}
: ${MARIADB_TEST_DATABASE:="${AUTH_API_MARIADB_DATABASE}"}
: ${MARIADB_TEST_KEY:="/run/harbor/auth/user/tls.key"}
: ${MARIADB_TEST_CERT:="/run/harbor/auth/user/tls.crt"}
: ${MARIADB_TEST_CA:="/run/harbor/auth/user/tls.ca"}
