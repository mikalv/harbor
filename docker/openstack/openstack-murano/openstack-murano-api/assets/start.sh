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
. /opt/harbor/service-hosts.sh
. /opt/harbor/harbor-common.sh
. /opt/harbor/murano/vars.sh
check_required_vars OS_DOMAIN \
                    MURANO_CONFIG_FILE


echo "${OS_DISTRO}: Testing service dependancies"
################################################################################
/usr/bin/mysql-test


echo "${OS_DISTRO}: Config Starting"
################################################################################
/opt/harbor/config-murano.sh


echo "${OS_DISTRO}: Component specific config starting"
################################################################################
/opt/harbor/murano/components/config-api.sh


echo "${OS_DISTRO}: Launching container application"
################################################################################
exec su -s /bin/sh -c "exec murano-api --config-file=${MURANO_CONFIG_FILE} --debug" murano
