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
echo "${OS_DISTRO}: Launching Container Startup Scripts"
################################################################################
/usr/bin/mysql-test


echo "${OS_DISTRO}: Configuring Keystone"
################################################################################
/opt/harbor/config-keystone.sh


echo "${OS_DISTRO}: Configuring branding"
################################################################################
/opt/harbor/config-keystone-branding.sh


echo "${OS_DISTRO}: Enable Debugging"
################################################################################
. /etc/os-container.env
. /opt/harbor/service-hosts.sh
. /opt/harbor/harbor-common.sh
. /opt/harbor/keystone/vars.sh
crudini --set ${KEYSTONE_CONFIG_FILE} DEFAULT debug "True"

echo "${OS_DISTRO}: Launching Container Application"
################################################################################
exec httpd -D FOREGROUND
