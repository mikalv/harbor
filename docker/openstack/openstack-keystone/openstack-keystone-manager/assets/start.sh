#!/bin/bash
set -e
echo "${OS_DISTRO}: Launching"
################################################################################
. /etc/os-container.env
. /opt/harbor/service-hosts.sh
. /opt/harbor/harbor-common.sh
. /opt/harbor/keystone/vars.sh


echo "${OS_DISTRO}: Config Starting"
################################################################################


echo "${OS_DISTRO}: Managing database"
################################################################################
/opt/harbor/keystone/config-database.sh
/opt/harbor/keystone/manage/bootstrap-database.sh


echo "${OS_DISTRO}: Managing tokens"
################################################################################
/opt/harbor/keystone/manage/manage-tokens.sh


echo "${OS_DISTRO}: Finished management"
################################################################################
tail -f /dev/null
