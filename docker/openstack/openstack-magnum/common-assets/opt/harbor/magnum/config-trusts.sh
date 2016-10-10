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
echo "${OS_DISTRO}: Configuring trusts"
################################################################################
. /etc/os-container.env
. /opt/harbor/service-hosts.sh
. /opt/harbor/harbor-common.sh
. /opt/harbor/magnum/vars.sh


################################################################################
check_required_vars MAGNUM_CONFIG_FILE \
                    AUTH_MAGNUM_KEYSTONE_TRUSTEE_PROJECT_DOMAIN \
                    AUTH_MAGNUM_KEYSTONE_TRUSTEE_USER \
                    AUTH_MAGNUM_KEYSTONE_TRUSTEE_PASSWORD


################################################################################
crudini --set ${MAGNUM_CONFIG_FILE} trust trustee_domain_name "${AUTH_MAGNUM_KEYSTONE_TRUSTEE_PROJECT_DOMAIN}"
crudini --set ${MAGNUM_CONFIG_FILE} trust trustee_domain_admin_name "${AUTH_MAGNUM_KEYSTONE_TRUSTEE_USER}"
crudini --set ${MAGNUM_CONFIG_FILE} trust trustee_domain_admin_password "${AUTH_MAGNUM_KEYSTONE_TRUSTEE_PASSWORD}"
crudini --set ${MAGNUM_CONFIG_FILE} trust roles "[]"
