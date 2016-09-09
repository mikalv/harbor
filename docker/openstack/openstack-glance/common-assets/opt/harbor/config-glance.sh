#!/bin/bash

# Copyright 2016 Port Direct
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -e
echo "${OS_DISTRO}: Glance Config Starting"
################################################################################
. /etc/os-container.env
. /opt/harbor/service-hosts.sh
. /opt/harbor/harbor-common.sh
. /opt/harbor/glance/vars.sh


################################################################################
check_required_vars GLANCE_CONFIG_FILE \
                    OS_DOMAIN


################################################################################
mkdir -p /etc/glance


echo "${OS_DISTRO}: Starting logging config"
################################################################################
/opt/harbor/glance/config-logging.sh


echo "${OS_DISTRO}: Starting database config"
################################################################################
/opt/harbor/glance/config-database.sh


echo "${OS_DISTRO}: Starting messaging config"
################################################################################
/opt/harbor/glance/config-messaging.sh


echo "${OS_DISTRO}: Starting keystone config"
################################################################################
/opt/harbor/glance/config-keystone.sh


echo "${OS_DISTRO}: Starting interaction config"
################################################################################
/opt/harbor/glance/config-interaction.sh
