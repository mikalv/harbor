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
check_required_vars NEUTRON_CONFIG_FILE \
                    PUBLIC_NET_NAME \
                    PUBLIC_SUBNET_NAME \
                    PUBLIC_IP_START \
                    PUBLIC_IP_END \
                    PUBLIC_GATEWAY \
                    PUBLIC_IP_RANGE \
                    ADMIN_ROUTER_NAME \
                    ADMIN_NET_NAME \
                    ADMIN_SUBNET_NAME \
                    ADMIN_IP_RANGE


################################################################################
neutron net-show "${PUBLIC_NET_NAME}" || neutron net-create \
--description="Public Network" \
--router:external=True \
--provider:physical_network=public \
--provider:network_type=flat \
"${PUBLIC_NET_NAME}"


################################################################################
neutron subnet-show "${PUBLIC_SUBNET_NAME}" || neutron subnet-create  \
--name="${PUBLIC_SUBNET_NAME}" \
--description="Public Subnet" \
--allocation-pool="start=${PUBLIC_IP_START},end=${PUBLIC_IP_END}" \
--disable-dhcp \
--gateway="${PUBLIC_GATEWAY%/*}" \
"${PUBLIC_NET_NAME}" \
"${PUBLIC_IP_RANGE}"


################################################################################
neutron net-show "${ADMIN_NET_NAME}" || neutron net-create \
--description="Admin Network" \
"${ADMIN_NET_NAME}"


################################################################################
neutron subnet-show "${ADMIN_SUBNET_NAME}" || neutron subnet-create \
--description="Admin Subnet" \
--name "${ADMIN_SUBNET_NAME}" \
"${ADMIN_NET_NAME}" \
"${ADMIN_IP_RANGE}"


################################################################################
neutron router-show ${ADMIN_ROUTER_NAME} ||  neutron router-create \
--description "Router for ${ADMIN_NET_NAME}" \
${ADMIN_ROUTER_NAME}


################################################################################
neutron router-gateway-set \
"${ADMIN_ROUTER_NAME}" \
"${PUBLIC_NET_NAME}"
neutron router-interface-add \
"${ADMIN_ROUTER_NAME}" \
"${ADMIN_SUBNET_NAME}" || true
