#!/bin/bash

: ${CEILOMETER_ELS_SERVICE_PORT:="9200"}
: ${CEILOMETER_ELS_SERVICE_HOST_SVC:="${CEILOMETER_API_SERVICE_HOSTNAME}-els.${CEILOMETER_SERVICE_NAMESPACE}.svc.$OS_DOMAIN"}
: ${CEILOMETER_ELS_CA:="/run/harbor/auth/els/tls.ca"}
: ${CEILOMETER_ELS_KEY:="/run/harbor/auth/els/tls.key"}
: ${CEILOMETER_ELS_CERT:="/run/harbor/auth/els/tls.crt"}


: ${ELASTICSEARCH_ROOT:="/usr/share/elasticsearch"}
: ${ELS_CONFIG_DIR:="${ELASTICSEARCH_ROOT}/config"}
: ${ELS_DATA_DIR:="${ELASTICSEARCH_ROOT}/data"}
