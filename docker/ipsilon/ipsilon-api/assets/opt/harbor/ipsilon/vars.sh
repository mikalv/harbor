#!/bin/bash
: ${IPSILON_API_SERVICE_PORT:="4143"}
: ${IPSILON_API_TLS_CA:="/run/harbor/auth/ssl/ca"}
: ${IPSILON_API_TLS_KEY:="/run/harbor/auth/ssl/key"}
: ${IPSILON_API_TLS_CERT:="/run/harbor/auth/ssl/crt"}

: ${IPSILON_DB_SERVICE_PORT:="5432"}
: ${IPSILON_DB_CA:="/run/harbor/auth/user/ca"}
: ${IPSILON_DB_KEY:="/run/harbor/auth/user/key"}
: ${IPSILON_DB_CERT:="/run/harbor/auth/user/crt"}
: ${IPSILON_DB_SERVICE_HOST_SVC:="${IPSILON_HOSTNAME}-db.${IPSILON_SERVICE_NAMESPACE}.svc.$OS_DOMAIN"}
: ${IPSILON_DATABASES:="DB ADMIN_DB USERS_DB TRANS_DB SAML2SESSION_DB SAMLSESSION_DB OPENID_DB OPENIDC_DB"}

: ${APACHE_CONFIG_FILE:="/etc/httpd/conf/httpd.conf"}
: ${APACHE_SSL_CONFIG_FILE:="/etc/httpd/conf.d/ssl.conf"}
: ${APACHE_RW_CONFIG_FILE:="/etc/httpd/conf.d/ipsilon-rewrite.conf"}
