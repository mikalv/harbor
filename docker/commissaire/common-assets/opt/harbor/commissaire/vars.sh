#!/bin/bash
: ${COMMISSAIRE_CONFIG_FILE:="/etc/commissaire/config.conf"}
: ${COMMISSAIRE_STOARGE_CONFIG_FILE:="/etc/commissaire/storage.conf"}
: ${COMMISSAIRE_INVESTIGATOR_CONFIG_FILE:="/etc/commissaire/investigator.conf"}

: ${COMMISSAIRE_API_SVC_PORT:="8001"}
: ${COMMISSAIRE_API_TLS_CA:="/run/harbor/auth/ssl/tls.ca"}
: ${COMMISSAIRE_API_TLS_KEY:="/run/harbor/auth/ssl/tls.key"}
: ${COMMISSAIRE_API_TLS_CERT:="/run/harbor/auth/ssl/tls.crt"}
: ${COMMISSAIRE_API_PEM_FILE:="/etc/commissaire/sever.pem"}


: ${COMMISSAIRE_API_SERVICE_HOSTNAME:="commissaire"}
: ${COMMISSAIRE_SERVICE_NAMESPACE:="os-commissaire"}
: ${COMMISSAIRE_ETCD_SERVICE_HOST_SVC:="${COMMISSAIRE_API_SERVICE_HOSTNAME}-etcd.${COMMISSAIRE_SERVICE_NAMESPACE}.svc.${OS_DOMAIN}"}
: ${COMMISSAIRE_ETCD_SVC_PORT:="2379"}

: ${COMMISSAIRE_DB_CA:="/run/harbor/auth/user/tls.ca"}
: ${COMMISSAIRE_DB_KEY:="/run/harbor/auth/user/tls.key"}
: ${COMMISSAIRE_DB_CERT:="/run/harbor/auth/user/tls.crt"}
