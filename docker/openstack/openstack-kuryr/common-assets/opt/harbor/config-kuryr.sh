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
echo "${OS_DISTRO}: Kuyr Config Starting"
################################################################################
. /etc/os-container.env
. /opt/harbor/service-hosts.sh
. /opt/harbor/harbor-common.sh
. /opt/harbor/kuryr/vars.sh


################################################################################
check_required_vars KURYR_CONFIG_FILE \
                    OS_DOMAIN


################################################################################
mkdir -p /etc/kuryr


echo "${OS_DISTRO}: Starting neutron config"
################################################################################
/opt/harbor/kuryr/config-neutron.sh


echo "${OS_DISTRO}: Starting kuryr config"
################################################################################
/opt/harbor/kuryr/config-kuryr.sh
