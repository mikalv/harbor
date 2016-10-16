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


echo "${OS_DISTRO}: Starting logging config"
################################################################################
/opt/harbor/keystone/config-logging.sh


echo "${OS_DISTRO}: Starting database config"
################################################################################
/opt/harbor/keystone/config-database.sh


echo "${OS_DISTRO}: Starting api-pipeline config"
################################################################################
/opt/harbor/keystone/config-api-pipeline.sh


echo "${OS_DISTRO}: Starting tokens config"
################################################################################
/opt/harbor/keystone/config-tokens.sh


echo "${OS_DISTRO}: Starting domains config"
################################################################################
/opt/harbor/keystone/config-domains.sh


echo "${OS_DISTRO}: Starting federation config"
################################################################################
/opt/harbor/keystone/config-federation.sh


echo "${OS_DISTRO}: Starting apache config"
################################################################################
/opt/harbor/keystone/config-apache.sh


echo "${OS_DISTRO}: Starting cors config"
################################################################################
/opt/harbor/keystone/config-cors.sh
