#!/bin/bash
: ${CEILOMETER_CONFIG_FILE:="/etc/ceilometer/ceilometer.conf"}
: ${CEILOMETER_HTTPD_CONFIG_FILE:="/etc/httpd/conf.d/ceilometer.conf"}

: ${CEILOMETER_MARIADB_SERVICE_PORT:="3321"}
: ${CEILOMETER_MARIADB_SERVICE_HOST_SVC:="${CEILOMETER_API_SERVICE_HOSTNAME}-db.${CEILOMETER_SERVICE_NAMESPACE}.svc.$OS_DOMAIN"}
: ${CEILOMETER_DB_CA:="/run/harbor/auth/user/tls.ca"}
: ${CEILOMETER_DB_KEY:="/run/harbor/auth/user/tls.key"}
: ${CEILOMETER_DB_CERT:="/run/harbor/auth/user/tls.crt"}

: ${CEILOMETER_ELS_SERVICE_PORT:="9200"}
: ${CEILOMETER_ELS_SERVICE_HOST_SVC:="${CEILOMETER_API_SERVICE_HOSTNAME}-els.${CEILOMETER_SERVICE_NAMESPACE}.svc.$OS_DOMAIN"}
: ${CEILOMETER_ELS_CA:="/run/harbor/auth/user/tls.ca"}
: ${CEILOMETER_ELS_KEY:="/run/harbor/auth/user/tls.key"}
: ${CEILOMETER_ELS_CERT:="/run/harbor/auth/user/tls.crt"}

: ${CEILOMETER_API_SVC_PORT:="8777"}
: ${CEILOMETER_API_TLS_CA:="/run/harbor/auth/ssl/tls.ca"}
: ${CEILOMETER_API_TLS_KEY:="/run/harbor/auth/ssl/tls.key"}
: ${CEILOMETER_API_TLS_CERT:="/run/harbor/auth/ssl/tls.crt"}

: ${AUTH_CEILOMETER_KEYSTONE_PROJECT:="service"}
: ${AUTH_CEILOMETER_KEYSTONE_PROJECT_DOMAIN:="default"}
: ${AUTH_CEILOMETER_KEYSTONE_PROJECT_USER_ROLE:="admin"}
: ${AUTH_CEILOMETER_KEYSTONE_DOMAIN:="default"}
: ${AUTH_CEILOMETER_KEYSTONE_REGION:="RegionOne"}

: ${GNOCCHI_ARCHIVE_POLICY:="Low"}

: ${CEILOMETER_NOTIFICATION_TOPICS:="notifications"}

# curl -XPUT -u elastic 'localhost:9200/_xpack/security/user/elastic/_password' -d '{
#   "password" : "elasticpassword"
# }'
