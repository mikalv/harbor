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
echo "${OS_DISTRO}: Configuring domain"
################################################################################
. /etc/os-container.env
. /opt/harbor/service-hosts.sh
. /opt/harbor/harbor-common.sh
. /opt/harbor/heat/vars.sh


################################################################################
check_required_vars HEAT_CONFIG_FILE \
                    OS_DOMAIN \
                    HEAT_DB_CA \
                    AUTH_HEAT_KEYSTONE_DOMAIN_DOMAIN \
                    AUTH_HEAT_KEYSTONE_DOMAIN_USER \
                    AUTH_HEAT_KEYSTONE_DOMAIN_PASSWORD


################################################################################
crudini --set $HEAT_CONFIG_FILE DEFAULT stack_user_domain_name "${AUTH_HEAT_KEYSTONE_DOMAIN_DOMAIN}"
crudini --set $HEAT_CONFIG_FILE DEFAULT stack_domain_admin "${AUTH_HEAT_KEYSTONE_DOMAIN_USER}"
crudini --set $HEAT_CONFIG_FILE DEFAULT stack_domain_admin_password "${AUTH_HEAT_KEYSTONE_DOMAIN_PASSWORD}"
