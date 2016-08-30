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



echo "${OS_DISTRO}: Finished management"
################################################################################
tail -f /dev/null


################################################################################
check_required_vars NEUTRON_CONFIG_FILE \
                    NEUTRON_ML2_CONFIG_FILE
exec neutron-server --config-file ${NEUTRON_CONFIG_FILE} --config-file ${NEUTRON_ML2_CONFIG_FILE} --debug
