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
echo "${OS_DISTRO}: Configuring rootwrap"
################################################################################
. /etc/os-container.env
. /opt/harbor/service-hosts.sh
. /opt/harbor/harbor-common.sh
. /opt/harbor/neutron/vars.sh


################################################################################
check_required_vars NEUTRON_CONFIG_FILE \
                    OS_DOMAIN


################################################################################
crudini --set ${NEUTRON_CONFIG_FILE} agent extensions "qos"
crudini --set ${NEUTRON_CONFIG_FILE} agent root_helper_daemon "sudo /usr/bin/neutron-rootwrap-daemon /etc/neutron/rootwrap.conf"
crudini --set ${NEUTRON_CONFIG_FILE} agent root_helper "sudo /usr/bin/neutron-rootwrap /etc/neutron/rootwrap.conf"
