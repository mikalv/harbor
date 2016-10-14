#!/bin/sh
set -e
################################################################################
. /etc/os-container.env
. /opt/harbor/service-hosts.sh
. /opt/harbor/harbor-common.sh

: ${MELLON_CONFIG:="/etc/httpd/conf.d/mellon-proxy.conf"}
: ${HOST_NAME:="${GNOCCHI_GRAFANA_SERVICE_HOST}"}
sed -i "s|{{ MY_IP }}|${MY_IP}|g" ${MELLON_CONFIG}
sed -i "s|{{ PORT_EXPOSE }}|${PORT_EXPOSE}|g" ${MELLON_CONFIG}
sed -i "s|{{ PORT_LOCAL }}|${PORT_LOCAL}|g" ${MELLON_CONFIG}
sed -i "s|{{ HOST_NAME }}|${HOST_NAME}|g" ${MELLON_CONFIG}


echo "${OS_DISTRO}: LAUNCHING APACHE"
################################################################################
exec httpd -D FOREGROUND
