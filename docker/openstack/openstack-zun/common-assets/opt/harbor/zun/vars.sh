#!/bin/bash
: ${ZUN_CONFIG_FILE:="/etc/zun/zun.conf"}

: ${ZUN_MARIADB_SERVICE_PORT:="3321"}
: ${ZUN_MARIADB_SERVICE_HOST_SVC:="${ZUN_API_SERVICE_HOSTNAME}-db.${ZUN_SERVICE_NAMESPACE}.svc.$OS_DOMAIN"}
: ${ZUN_DB_CA:="/run/harbor/auth/user/tls.ca"}
: ${ZUN_DB_KEY:="/run/harbor/auth/user/tls.key"}
: ${ZUN_DB_CERT:="/run/harbor/auth/user/tls.crt"}

: ${ZUN_ETCD_SERVICE_PORT:="4004"}
: ${ZUN_ETCD_PEER_PORT:="7004"}
: ${ZUN_ETCD_SERVICE_HOST_SVC:="${ZUN_API_SERVICE_HOSTNAME}-etcd.${ZUN_SERVICE_NAMESPACE}.svc.$OS_DOMAIN"}
: ${ZUN_ETCD_CA:="${ZUN_DB_CA}"}
: ${ZUN_ETCD_KEY:="${ZUN_ETCD_KEY}"}
: ${ZUN_ETCD_CERT:="${ZUN_ETCD_CERT}"}

: ${ZUN_API_SVC_PORT:="9517"}
: ${ZUN_API_TLS_CA:="/run/harbor/auth/ssl/tls.ca"}
: ${ZUN_API_TLS_KEY:="/run/harbor/auth/ssl/tls.key"}
: ${ZUN_API_TLS_CERT:="/run/harbor/auth/ssl/tls.crt"}

: ${AUTH_ZUN_KEYSTONE_PROJECT:="service"}
: ${AUTH_ZUN_KEYSTONE_PROJECT_DOMAIN:="default"}
: ${AUTH_ZUN_KEYSTONE_PROJECT_USER_ROLE:="admin"}
: ${AUTH_ZUN_KEYSTONE_DOMAIN:="default"}
: ${AUTH_ZUN_KEYSTONE_REGION:="RegionOne"}
