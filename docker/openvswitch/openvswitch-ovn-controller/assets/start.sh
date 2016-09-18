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
echo "${OS_DISTRO}: Launching OVS DB Container"
################################################################################
. /etc/os-container.env
. /opt/harbor/service-hosts.sh
. /opt/harbor/harbor-common.sh


################################################################################
INTERGRATION_BRIDGE=${INTERGRATION_BRIDGE:-"br-int"}
EXTERNAL_BRIDGE=${EXTERNAL_BRIDGE:-"br-ex"}
SYSTEM_ID="$(hostname -s).${OS_DOMAIN}"


################################################################################
check_required_vars OS_DOMAIN \
                    MY_IP \
                    INTERGRATION_BRIDGE \
                    OVN_SB_DB_SERVICE_HOST_SVC \
                    SYSTEM_ID

################################################################################
OVS_SB_DB_IP=$(dig +short ${OVN_SB_DB_SERVICE_HOST_SVC} | awk '{ print ; exit }')
check_required_vars OVS_SB_DB_IP


echo "${OS_DISTRO}: Setting Systemid to ${SYSTEM_ID}"
################################################################################
ovs-vsctl --no-wait init
ovs-vsctl --no-wait set open_vswitch . system-type="HarborOS"
ovs-vsctl --no-wait set open_vswitch . external-ids:system-id="${SYSTEM_ID}"


echo "${OS_DISTRO}: Setting OVS-SB connection to ${OVS_SB_DB_IP}"
################################################################################
ovs-vsctl --no-wait set open_vswitch . external-ids:ovn-remote="tcp:${OVS_SB_DB_IP}:6642"


echo "${OS_DISTRO}: Setting intergration bridge to ${INTERGRATION_BRIDGE}"
################################################################################
ovs-vsctl --no-wait set open_vswitch . external-ids:ovn-bridge="${INTERGRATION_BRIDGE}"


echo "${OS_DISTRO}: Setting geneve encapsulation ip to ${MY_IP}"
################################################################################
ovs-vsctl --no-wait set open_vswitch . external-ids:ovn-encap-type="geneve"
ovs-vsctl --no-wait set open_vswitch . external-ids:ovn-encap-ip="${MY_IP}"


echo "${OS_DISTRO}: Configuring intergration bridge (${INTERGRATION_BRIDGE})"
################################################################################
ovs-vsctl --no-wait --may-exist add-br ${INTERGRATION_BRIDGE}
ovs-vsctl --no-wait br-set-external-id ${INTERGRATION_BRIDGE} bridge-id ${INTERGRATION_BRIDGE}
ovs-vsctl --no-wait set bridge br-int fail-mode=secure other-config:disable-in-band=true


if ! [ -z "${EXTERNAL_BRIDGE}" ]; then
  echo "${OS_DISTRO}: Configuring external bridge (${EXTERNAL_BRIDGE})"
  ################################################################################
  ovs-vsctl --no-wait --may-exist add-br ${EXTERNAL_BRIDGE} -- set bridge ${EXTERNAL_BRIDGE} protocols=OpenFlow13
  ovs-vsctl --no-wait set open . external-ids:ovn-bridge-mappings=public:${EXTERNAL_BRIDGE}
fi


echo "${OS_DISTRO}: Launching Container Application"
################################################################################
exec ovn-controller unix:/var/run/openvswitch/db.sock \
      --log-file="/dev/null"
