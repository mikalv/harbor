#!/bin/bash
set -e
echo "${OS_DISTRO}: Launching"
################################################################################
. /etc/os-container.env
. /opt/harbor/service-hosts.sh
. /opt/harbor/harbor-common.sh
. /opt/harbor/horizon/vars.sh


echo "${OS_DISTRO}: Config Starting"
################################################################################


echo "${OS_DISTRO}: Managing horizon"
################################################################################
/opt/harbor/horizon/config-horizon.sh


echo "${OS_DISTRO}: Managing database"
################################################################################
/opt/stack/horizon/manage.py migrate



echo "${OS_DISTRO}: Finished management"
################################################################################
tail -f /dev/null
