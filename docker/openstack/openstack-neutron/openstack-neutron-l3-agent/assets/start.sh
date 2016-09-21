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


echo "${OS_DISTRO}: Configuring Container"
################################################################################
check_required_vars NEUTRON_CONFIG_FILE \
                    OS_DOMAIN \
                    NEUTRON_L3_CONFIG_FILE


echo "${OS_DISTRO}: Starting neutron config"
################################################################################
/opt/harbor/config-neutron.sh


echo "${OS_DISTRO}: Starting l3-agent config"
################################################################################
/opt/harbor/neutron/components/config-l3-agent.sh


echo "${OS_DISTRO}: Removing any existing network namespaces"
################################################################################
ip netns list | grep "^qrouter" | while read -r NET_NS ; do
  ip netns delete $NET_NS
done
# why do we have to run this twice sometimes?
ip netns list | grep "^qrouter" | while read -r NET_NS ; do
  ip netns delete $NET_NS
done


echo "${OS_DISTRO}: Launching Application"
################################################################################
exec su -s /bin/sh -c "exec neutron-l3-agent --debug \
                      --config-file ${NEUTRON_CONFIG_FILE} \
                      --config-file ${NEUTRON_L3_CONFIG_FILE}" neutron
