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
echo "${OS_DISTRO}: Configuring plugins"
################################################################################
. /etc/os-container.env
. /opt/harbor/service-hosts.sh
. /opt/harbor/harbor-common.sh
. /opt/harbor/neutron/vars.sh


################################################################################
check_required_vars NEUTRON_CONFIG_FILE \
                    OS_DOMAIN \
                    OVN_L3_MODE


################################################################################
crudini --set ${NEUTRON_CONFIG_FILE} DEFAULT core_plugin "neutron.plugins.ml2.plugin.Ml2Plugin"


################################################################################
if [ "$OVN_L3_MODE" = "True" ]; then
  L3_ROUTER_PLUGIN="networking_ovn.l3.l3_ovn.OVNL3RouterPlugin"
else
  L3_ROUTER_PLUGIN="neutron.services.l3_router.l3_router_plugin.L3RouterPlugin"
fi;
check_required_vars L3_ROUTER_PLUGIN
crudini --set ${NEUTRON_CONFIG_FILE} DEFAULT service_plugins \
    "${L3_ROUTER_PLUGIN},neutron.services.qos.qos_plugin.QoSPlugin,neutron_lbaas.services.loadbalancer.plugin.LoadBalancerPluginv2"
