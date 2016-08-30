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
echo "${OS_DISTRO}: Configuring ovn"
################################################################################
. /etc/os-container.env
. /opt/harbor/service-hosts.sh
. /opt/harbor/harbor-common.sh
. /opt/harbor/neutron/vars.sh


################################################################################
check_required_vars NEUTRON_ML2_CONFIG_FILE \
                    OS_DOMAIN \
                    OVN_L3_MODE \
                    OVS_SB_DB_IP \
                    OVS_NB_DB_IP


mkdir -p $(dirname ${NEUTRON_ML2_CONFIG_FILE})

################################################################################
crudini --set ${NEUTRON_ML2_CONFIG_FILE} agent extensions "qos"


################################################################################
crudini --set ${NEUTRON_ML2_CONFIG_FILE} ml2 tenant_network_types "geneve"
crudini --set ${NEUTRON_ML2_CONFIG_FILE} ml2 extension_drivers "qos,port_security"
crudini --set ${NEUTRON_ML2_CONFIG_FILE} ml2 type_drivers "local,flat,vlan,geneve"
crudini --set ${NEUTRON_ML2_CONFIG_FILE} ml2 mechanism_drivers "ovn,logger"
crudini --set ${NEUTRON_ML2_CONFIG_FILE} ml2 overlay_ip_version "4"


################################################################################
crudini --set ${NEUTRON_ML2_CONFIG_FILE} ml2_type_flat flat_networks "*"


################################################################################
crudini --set ${NEUTRON_ML2_CONFIG_FILE} ml2_type_vxlan vxlan_group ""
crudini --set ${NEUTRON_ML2_CONFIG_FILE} ml2_type_vxlan vni_ranges "1:1000"


################################################################################
crudini --set ${NEUTRON_ML2_CONFIG_FILE} ml2_type_geneve vni_ranges "1:65536"
crudini --set ${NEUTRON_ML2_CONFIG_FILE} ml2_type_geneve max_header_size "38"


################################################################################
crudini --set ${NEUTRON_ML2_CONFIG_FILE} ml2_type_gre tunnel_id_ranges "1:1000"


################################################################################
crudini --set ${NEUTRON_ML2_CONFIG_FILE} securitygroup enable_security_group "True"
crudini --set ${NEUTRON_ML2_CONFIG_FILE} securitygroup enable_ipset "True"


################################################################################
crudini --set ${NEUTRON_ML2_CONFIG_FILE} ovn neutron_sync_mode "repair"
crudini --set ${NEUTRON_ML2_CONFIG_FILE} ovn ovn_sb_connection "tcp:${OVS_SB_DB_IP}:6642"
crudini --set ${NEUTRON_ML2_CONFIG_FILE} ovn ovn_nb_connection "tcp:${OVS_NB_DB_IP}:6641"
crudini --set ${NEUTRON_ML2_CONFIG_FILE} ovn ovn_l3_mode "${OVN_L3_MODE}"
crudini --set ${NEUTRON_ML2_CONFIG_FILE} ovn ovn_l3_scheduler "leastloaded"
crudini --set ${NEUTRON_ML2_CONFIG_FILE} ovn ovn_native_dhcp "True"
crudini --set ${NEUTRON_ML2_CONFIG_FILE} ovn ovsdb_connection "tcp:127.0.0.1:6640"
crudini --set ${NEUTRON_ML2_CONFIG_FILE} ovn vif_type "ovs"
