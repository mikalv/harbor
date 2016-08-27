#!/bin/bash
set -e
echo "${OS_DISTRO}: Configuring API pipeline"
################################################################################
. /etc/os-container.env
. /opt/harbor/service-hosts.sh
. /opt/harbor/harbor-common.sh
. /opt/harbor/keystone/vars.sh


################################################################################
check_required_vars KEYSTONE_CONFIG_FILE \
                    KEYSTONE_API_PASTE_CONFIG_FILE \
                    OS_DOMAIN


################################################################################
crudini --set ${KEYSTONE_API_PASTE_CONFIG_FILE} pipeline:public_api pipeline "cors sizelimit url_normalize request_id build_auth_context token_auth json_body ec2_extension public_service"
crudini --set ${KEYSTONE_API_PASTE_CONFIG_FILE} pipeline:admin_api pipeline "cors sizelimit url_normalize request_id build_auth_context token_auth json_body ec2_extension s3_extension admin_service"
crudini --set ${KEYSTONE_API_PASTE_CONFIG_FILE} pipeline:api_v3 pipeline "cors sizelimit url_normalize request_id build_auth_context token_auth json_body ec2_extension_v3 s3_extension service_v3"
crudini --set ${KEYSTONE_CONFIG_FILE} paste_deploy config_file "$KEYSTONE_API_PASTE_CONFIG_FILE"
