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
: ${OS_DISTRO:="HarborOS: Init"}
echo "${OS_DISTRO}: Container starting"
################################################################################
. /usr/sbin/container-gen-env
touch /etc/os-container.env
source /etc/os-container.env
source /opt/harbor/harbor-vars.sh
. /opt/harbor/service-hosts.sh
. /opt/harbor/harbor-common.sh

echo "${OS_DISTRO}: Running boot checks"
################################################################################
boot_checks



echo "${OS_DISTRO}:Setting Up user"
################################################################################
/opt/harbor/portal/manage/manage-keystone-user.sh



echo "${OS_DISTRO}: Finished management"
################################################################################
tail -f /dev/null
