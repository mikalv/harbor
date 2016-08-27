#!/bin/bash
set -e
echo "${OS_DISTRO}: Configuring domains"
################################################################################
. /etc/os-container.env
. /opt/harbor/service-hosts.sh
. /opt/harbor/harbor-common.sh
. /opt/harbor/keystone/vars.sh


################################################################################
check_required_vars KEYSTONE_CONFIG_FILE \
                    OS_DOMAIN


################################################################################
crudini --set ${KEYSTONE_CONFIG_FILE} identity domain_specific_drivers_enabled "true"
crudini --set ${KEYSTONE_CONFIG_FILE} identity domain_configurations_from_database "true"
