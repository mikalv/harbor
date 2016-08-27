#!/bin/bash
set -e
echo "${OS_DISTRO}: Configuring federation"
################################################################################
. /etc/os-container.env
. /opt/harbor/service-hosts.sh
. /opt/harbor/harbor-common.sh
. /opt/harbor/keystone/vars.sh


################################################################################
check_required_vars KEYSTONE_CONFIG_FILE \
                    OS_DOMAIN


################################################################################
crudini --set ${KEYSTONE_CONFIG_FILE} auth methods "external,password,token,saml2"
crudini --set ${KEYSTONE_CONFIG_FILE} federation remote_id_attribute "MELLON_IDP"
crudini --set ${KEYSTONE_CONFIG_FILE} federation trusted_dashboard "https://api.${OS_DOMAIN}/auth/websso/"
