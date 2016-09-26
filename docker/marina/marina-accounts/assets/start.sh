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
: ${OS_DISTRO:="HarborOS: Auth"}
echo "${OS_DISTRO}: Starting service auth update"
################################################################################
tail -f /dev/null
. /etc/os-container.env
. /opt/harbor/service-hosts.sh
. /opt/harbor/harbor-common.sh



echo "${OS_DISTRO}: Configuring Email"
################################################################################
/opt/harbor/portal/activate/config-email.sh



export SWEEP_INTERVAL=120
################################################################################
echo "${OS_DISTRO}: ${OPENSTACK_COMPONENT}: ${OPENSTACK_SUBCOMPONENT}: Running user activation script every ${SWEEP_INTERVAL} seconds"
################################################################################
while true; do
    /opt/harbor/portal/activate/activate-staged-users.sh
    sleep $SWEEP_INTERVAL
done
