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
echo "${OS_DISTRO}: Launching"
################################################################################
. /etc/os-container.env
. /opt/harbor/service-hosts.sh
. /opt/harbor/harbor-common.sh
. /opt/harbor/keystone/vars.sh


################################################################################
check_required_vars OS_DOMAIN \
                    KEYSTONE_CONFIG_FILE \
                    APP_COMPONENT \
                    APP_USER


echo "${OS_DISTRO}: Testing DB Connection"
################################################################################
/usr/bin/mysql-test


echo "${OS_DISTRO}: Common config starting"
################################################################################
/opt/harbor/config-keystone.sh


echo "${OS_DISTRO}: Component specific config starting"
################################################################################
/opt/harbor/keystone/components/config-${APP_COMPONENT}.sh


echo "${OS_DISTRO}: Moving pod configs into place"
################################################################################
cp -rfav $(dirname ${KEYSTONE_CONFIG_FILE})/* /pod$(dirname ${KEYSTONE_CONFIG_FILE})/
if [ "$APP_COMPONENT" == "api" ]; then
  check_required_vars KEYSTONE_APACHE_CONFIG_FILE KEYSTONE_SSO_CALLBACK_TEMPLATE
  cp -rfav $(dirname ${KEYSTONE_APACHE_CONFIG_FILE})/* /pod$(dirname ${KEYSTONE_APACHE_CONFIG_FILE})/
  chown ${APP_USER}:${APP_USER} /pod${KEYSTONE_SSO_CALLBACK_TEMPLATE}
fi


echo "${OS_DISTRO}: Pod init finished"
################################################################################
