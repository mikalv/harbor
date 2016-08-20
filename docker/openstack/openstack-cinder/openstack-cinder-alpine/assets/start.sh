#!/bin/sh
set -e
set -x
echo "${OS_DISTRO}: ${OS_COMP}: Starting Container"
source /etc/os-container.env
. /opt/harbor/service-hosts.sh
. /opt/harbor/harbor-common.sh
# File path and name used by crudini tool
export cfg=/etc/${OS_COMP}/${OS_COMP}.conf


echo "${OS_DISTRO}: ${OS_COMP}: Launching"
exec tail -f /dev/null
