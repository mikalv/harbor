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
. /opt/harbor/neutron/vars.sh


################################################################################
check_required_vars OS_DOMAIN \
                    NEUTRON_CONFIG_FILE


echo "${OS_DISTRO}: Common config starting"
################################################################################
/opt/harbor/config-neutron.sh


echo "${OS_DISTRO}: Component specific config starting"
################################################################################
/opt/harbor/neutron/components/config-${APP_COMPONENT}.sh


echo "${OS_DISTRO}: Moving pod configs into place"
################################################################################
cp -rfav $(dirname ${NEUTRON_CONFIG_FILE})/* /pod$(dirname ${NEUTRON_CONFIG_FILE})/


echo "${OS_DISTRO}: Pod init finished"
################################################################################
