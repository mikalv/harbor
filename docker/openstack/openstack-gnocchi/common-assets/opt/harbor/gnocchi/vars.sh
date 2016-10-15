#!/bin/bash
: ${GNOCCHI_CONFIG_FILE:="/etc/gnocchi/gnocchi.conf"}
: ${GNOCCHI_PASTE_CONFIG_FILE:="/etc/gnocchi/api-paste.ini"}
: ${GNOCCHI_UWSGI_CONFIG_FILE:="/etc/gnocchi/uwsgi.ini"}

: ${GNOCCHI_MARIADB_SERVICE_PORT:="3320"}
: ${GNOCCHI_MARIADB_SERVICE_HOST_SVC:="${GNOCCHI_API_SERVICE_HOSTNAME}-db.${GNOCCHI_SERVICE_NAMESPACE}.svc.$OS_DOMAIN"}
: ${GNOCCHI_DB_CA:="/run/harbor/auth/user/tls.ca"}
: ${GNOCCHI_DB_KEY:="/run/harbor/auth/user/tls.key"}
: ${GNOCCHI_DB_CERT:="/run/harbor/auth/user/tls.crt"}

: ${GNOCCHI_API_SVC_PORT:="8041"}
: ${GNOCCHI_API_TLS_CA:="/run/harbor/auth/ssl/tls.ca"}
: ${GNOCCHI_API_TLS_KEY:="/run/harbor/auth/ssl/tls.key"}
: ${GNOCCHI_API_TLS_CERT:="/run/harbor/auth/ssl/tls.crt"}

: ${AUTH_GNOCCHI_KEYSTONE_PROJECT:="service"}
: ${AUTH_GNOCCHI_KEYSTONE_PROJECT_DOMAIN:="default"}
: ${AUTH_GNOCCHI_KEYSTONE_PROJECT_USER_ROLE:="admin"}
: ${AUTH_GNOCCHI_KEYSTONE_DOMAIN:="default"}
: ${AUTH_GNOCCHI_KEYSTONE_REGION:="RegionOne"}

: ${GNOCCHI_STATSD_SVC_PORT:="8125"}

: ${ETCD_LOCAL_PORT:="4002"}
: ${ETCD_LOCAL_URI:="etcd://127.0.0.1:${ETCD_LOCAL_PORT}/gnocchi"}

: ${GRAFANA_CONFIG_FILE:="/etc/grafana/grafana.ini"}
: ${GRAFANA_LDAP_CONFIG_FILE:="/etc/grafana/ldap.toml"}


: ${GNOCCHI_GRAFANA_SVC_PORT:="3000"}
: ${GNOCCHI_GRAFANA_SVC_PORT_LOCAL:="3000"}
: ${GRAFANA_IPA_REALM:="$(echo ${OS_DOMAIN} | tr '[:lower:]' '[:upper:]')"}
: ${GRAFANA_LDAP_BASE_DN:="dc=$(echo ${OS_DOMAIN} | sed 's/\./,dc=/g')"}

: ${GRAFANA_DB_SERVICE_PORT:="5433"}
: ${GRAFANA_DB_CA:="/run/harbor/auth/user/tls.ca"}
: ${GRAFANA_DB_KEY:="/run/harbor/auth/user/tls.key"}
: ${GRAFANA_DB_CERT:="/run/harbor/auth/user/tls.crt"}
: ${GRAFANA_DB_SERVICE_HOST_SVC:="${GNOCCHI_API_SERVICE_HOSTNAME}-pgsql.${GNOCCHI_SERVICE_NAMESPACE}.svc.$OS_DOMAIN"}
: ${GRAFANA_DATABASES:="DB"}
