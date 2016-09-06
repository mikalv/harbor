#!/bin/bash
: ${KEYSTONE_CONFIG_FILE:="/etc/keystone/keystone.conf"}
: ${KEYSTONE_API_PASTE_CONFIG_FILE:="/etc/keystone/keystone-paste.ini"}
: ${KEYSTONE_APACHE_CONFIG_FILE:="/etc/httpd/conf.d/wsgi-keystone.conf"}
: ${KEYSTONE_APACHE_MELLON_CONFIG_FILE:="/etc/httpd/conf.d/keystone-ipsilon.conf"}


: ${KEYSTONE_MARIADB_SERVICE_PORT:="3307"}
: ${KEYSTONE_DB_CA:="/run/harbor/auth/user/tls.ca"}
: ${KEYSTONE_DB_KEY:="/run/harbor/auth/user/tls.key"}
: ${KEYSTONE_DB_CERT:="/run/harbor/auth/user/tls.crt"}
: ${KEYSTONE_MARIADB_SERVICE_HOST_SVC:="${KEYSTONE_API_SERVICE_HOSTNAME}-db.${KEYSTONE_SERVICE_NAMESPACE}.svc.$OS_DOMAIN"}

: ${KEYSTONE_FERNET_KEYS_ROOT:="/etc/keystone/fernet-keys"}


: ${KEYSTONE_API_TLS_CA:="/run/harbor/auth/ssl/tls.ca"}
: ${KEYSTONE_API_TLS_KEY:="/run/harbor/auth/ssl/tls.key"}
: ${KEYSTONE_API_TLS_CERT:="/run/harbor/auth/ssl/tls.crt"}

: ${KEYSTONE_MELLON_ACTIVE:="False"}

: ${KEYSTONE_MELLON_SP_METADATA:="/run/harbor/auth/mellon/sp-metadata"}
: ${KEYSTONE_MELLON_SP_TLS_KEY:="/run/harbor/auth/mellon/tls.key"}
: ${KEYSTONE_MELLON_SP_TLS_CERT:="/run/harbor/auth/mellon/tls.crt"}
: ${KEYSTONE_MELLON_IDP_METADATA:="/run/harbor/auth/mellon/idp-metadata"}
