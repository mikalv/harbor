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
echo "${OS_DISTRO}: Launching Container Startup Scripts"
################################################################################
. /etc/os-container.env
. /opt/harbor/service-hosts.sh
. /opt/harbor/harbor-common.sh
. /opt/harbor/neutron/vars.sh
tail -f /dev/null


echo "${OS_DISTRO}: Configuring Container"
################################################################################
check_required_vars NEUTRON_CONFIG_FILE \
                    OS_DOMAIN


echo "${OS_DISTRO}: Testing service dependancies"
################################################################################
/usr/bin/mysql-test


echo "${OS_DISTRO}: Checking OVS"
################################################################################
if ! ovs-vsctl list-br | grep -q "^br-int"; then
  echo "${OS_DISTRO}: The integration brige does not yet exist in OVS, is it online?"
  echo "${OS_DISTRO}: Sleeping for 10s, before exiting"
  sleep 10
  exit 1
fi


echo "${OS_DISTRO}: Starting neutron config"
################################################################################
/opt/harbor/config-neutron.sh


echo "${OS_DISTRO}: Starting metadata-agent config"
################################################################################
/opt/harbor/neutron/components/config-metadata-agent.sh


echo "${OS_DISTRO}: Removing any existing network namespaces"
################################################################################
ip netns list | grep "^qmeta" | while read -r NET_NS ; do
  ip netns delete $NET_NS
done
# why do we have to run this twice sometimes?
ip netns list | grep "^qmeta" | while read -r NET_NS ; do
  ip netns delete $NET_NS
done


echo "${OS_DISTRO}: Launching metadata agents"
################################################################################
exec /usr/bin/supervisord -c /etc/supervisord.conf
