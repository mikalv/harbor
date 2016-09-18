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
echo "${OS_DISTRO}: Bootstrapping ext-net"
################################################################################
. /etc/os-container.env
. /opt/harbor/service-hosts.sh
. /opt/harbor/harbor-common.sh
. /opt/harbor/neutron/vars.sh
. /opt/harbor/neutron/manage/env-keystone-auth.sh

################################################################################
check_required_vars NEUTRON_CONFIG_FILE

# On host
PUBLIC_GATEWAY_IP=10.80.0.1/12
EXTERNAL_BRIDGE=${EXTERNAL_BRIDGE:-"br-ex"}
ip addr add ${PUBLIC_GATEWAY_IP} dev ${EXTERNAL_BRIDGE}
ip link set up ${EXTERNAL_BRIDGE}
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE



[public]
public_ip_range = 10.80.0.0/12
public_ip_start = 10.80.1.0
public_ip_end = 10.95.255.254
public_gateway = 10.80.0.1/12
public_dns = 8.8.8.8
public_subnet_name = ext-subnet
public_net_name = ext-net
public_net_dev = br-ex

[uplink]
uplink_ip_range = 10.64.0.0/16
uplink_gateway = 10.64.0.1
uplink_net_name = kuryr-uplink
uplink_router_name = kuryr-uplink

[admin]
admin_ip_range = 10.63.0.0/16
admin_gateway = 10.63.0.1
admin_net_name = admin
admin_subnet_name = admin
admin_router_name = admin

PUBLIC_NET_NAME=ext-net
PUBLIC_SUBNET_NAME=ext-subnet
PUBLIC_IP_START=10.80.1.0
PUBLIC_IP_END=10.95.255.254
PUBLIC_GATEWAY=10.80.0.1/12
PUBLIC_IP_RANGE=10.80.0.0/12


neutron net-create \
--description="Public Network" \
--router:external=True \
--provider:physical_network=public \
--provider:network_type=flat \
"${PUBLIC_NET_NAME}"
neutron subnet-create  \
--name="${PUBLIC_SUBNET_NAME}" \
--description="Public Subnet" \
--allocation-pool="start=${PUBLIC_IP_START},end=${PUBLIC_IP_END}" \
--disable-dhcp \
--gateway="${PUBLIC_GATEWAY%/*}" \
"${PUBLIC_NET_NAME}" \
"${PUBLIC_IP_RANGE}"


ADMIN_NET_NAME=admin
ADMIN_SUBNET_NAME=admin
ADMIN_IP_RANGE=10.63.0.0/16
neutron net-create \
--description="Admin Network" \
"${ADMIN_NET_NAME}"
neutron subnet-create \
--description="Admin Subnet" \
--name "${ADMIN_SUBNET_NAME}" \
"${ADMIN_NET_NAME}" \
"${ADMIN_IP_RANGE}"



ADMIN_ROUTER_NAME=admin
neutron router-create \
--description "Router for ${ADMIN_NET_NAME}" \
${ADMIN_ROUTER_NAME}
neutron router-gateway-set \
"${ADMIN_ROUTER_NAME}" \
"${PUBLIC_NET_NAME}"
neutron router-interface-add \
"${ADMIN_ROUTER_NAME}" \
"${ADMIN_SUBNET_NAME}"







neutron security-group-create \
--description "security rules to access demo instances" \
"demo"

neutron security-group-rule-create \
--description "Global SSH Access" \
--direction ingress \
--protocol tcp \
--port-range-min 22 \
--port-range-max 22 \
--remote-ip-prefix 0.0.0.0/0 \
"demo"

neutron security-group-rule-create \
--description "Global HTTP Access" \
--direction ingress \
--ethertype IPv4 \
--protocol tcp \
--port-range-min 80 \
--port-range-max 80 \
--remote-ip-prefix 0.0.0.0/0 \
"demo"

neutron security-group-rule-create \
--description "Global HTTPS Access" \
--direction ingress \
--ethertype IPv4 \
--protocol tcp \
--port-range-min 443 \
--port-range-max 443 \
--remote-ip-prefix 0.0.0.0/0 \
"demo"

neutron security-group-rule-create \
--description "Global ICMP Access" \
--direction ingress \
--ethertype IPv4 \
--protocol icmp \
--remote-ip-prefix 0.0.0.0/0 \
"demo"
