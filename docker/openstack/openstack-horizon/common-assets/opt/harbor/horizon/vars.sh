#!/bin/bash
: ${API_CONFIG_FILE:="/opt/stack/horizon/openstack_dashboard/local/local_settings.py"}
: ${API_CONFIG_FILE_TEMPLATE:="/opt/harbor/horizon/config/local_settings.py"}

: ${API_APACHE_CONFIG_FILE:="/etc/httpd/conf.d/horizon.conf"}


: ${HORIZON_API_SERVICE_PORT:="4433"}

: ${API_MARIADB_SERVICE_PORT:="3309"}
: ${API_DB_CA:="/run/harbor/auth/user/ca"}
: ${API_DB_KEY:="/run/harbor/auth/user/key"}
: ${API_DB_CERT:="/run/harbor/auth/user/crt"}
: ${API_MARIADB_SERVICE_HOST_SVC:="${HORIZON_API_SERVICE_HOSTNAME}-db.${HORIZON_SERVICE_NAMESPACE}.svc.$OS_DOMAIN"}


: ${API_TLS_CA:="/run/harbor/auth/ssl/ca"}
: ${API_TLS_KEY:="/run/harbor/auth/ssl/key"}
: ${API_TLS_CERT:="/run/harbor/auth/ssl/crt"}
