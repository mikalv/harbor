#!/bin/bash

# Copyright 2016 Port Direct
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

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
