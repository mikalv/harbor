#!/bin/bash
set -e
echo "${OS_DISTRO}: Keystone Config Starting"
################################################################################
. /etc/os-container.env
. /opt/harbor/service-hosts.sh
. /opt/harbor/harbor-common.sh
. /opt/harbor/keystone/vars.sh


################################################################################
check_required_vars KEYSTONE_CONFIG_FILE \
                    OS_DOMAIN


################################################################################
mkdir -p /etc/keystone


echo "${OS_DISTRO}: Configuring logging"
################################################################################
/opt/harbor/keystone/config-logging.sh


echo "${OS_DISTRO}: Configuring database"
################################################################################
/opt/harbor/keystone/config-database.sh


echo "${OS_DISTRO}: Configuring api pipeline"
################################################################################
/opt/harbor/keystone/config-api-pipeline.sh


echo "${OS_DISTRO}: Configuring tokens"
################################################################################
/opt/harbor/keystone/config-tokens.sh

# /opt/harbor/keystone/config-domains.sh
# /opt/harbor/keystone/config-federation.sh
# /opt/harbor/keystone/config-apache.sh
