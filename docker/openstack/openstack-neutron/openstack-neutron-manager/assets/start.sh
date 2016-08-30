#!/bin/bash
set -e
echo "${OS_DISTRO}: Launching"
################################################################################
. /etc/os-container.env
. /opt/harbor/service-hosts.sh
. /opt/harbor/harbor-common.sh
. /opt/harbor/neutron/vars.sh


echo "${OS_DISTRO}: Config Starting"
################################################################################
/opt/harbor/config-neutron.sh


echo "${OS_DISTRO}: Managing database"
################################################################################
/opt/harbor/neutron/manage/bootstrap-database.sh


echo "${OS_DISTRO}: Managing User"
################################################################################
/opt/harbor/neutron/manage/manage-keystone-user.sh


echo "${OS_DISTRO}: Managing Service"
################################################################################
/opt/harbor/neutron/manage/manage-keystone-service.sh


echo "${OS_DISTRO}: Finished management"
################################################################################
tail -f /dev/null
