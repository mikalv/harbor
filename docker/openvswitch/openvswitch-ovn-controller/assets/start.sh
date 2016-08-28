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

TUNNEL_DEV=${TUNNEL_DEV:-eth0}
HOST_IP="$(ip -f inet -o addr show ${TUNNEL_DEV}|cut -d\  -f 7 | cut -d/ -f 1)"
OVS_SB_DB_IP=${OVS_SB_DB_IP:-$HOST_IP}
INTERGRATION_BRIDGE=${INTERGRATION_BRIDGE:-br-int}

ovs-vsctl --no-wait init
ovs-vsctl --no-wait set open_vswitch . system-type="HarborOS"
ovs-vsctl --no-wait set open_vswitch . external-ids:system-id="$(hostname -s).$(hostname -d)"

ovs-vsctl --no-wait set open_vswitch . external-ids:ovn-remote="tcp:${OVS_SB_DB_IP}:6642"
ovs-vsctl --no-wait set open_vswitch . external-ids:ovn-bridge="${INTERGRATION_BRIDGE}"
ovs-vsctl --no-wait set open_vswitch . external-ids:ovn-encap-type="geneve"
ovs-vsctl --no-wait set open_vswitch . external-ids:ovn-encap-ip="$HOST_IP"

ovs-vsctl --no-wait -- --may-exist add-br ${INTERGRATION_BRIDGE}
ovs-vsctl --no-wait br-set-external-id ${INTERGRATION_BRIDGE} bridge-id ${INTERGRATION_BRIDGE}
ovs-vsctl --no-wait set bridge br-int fail-mode=secure other-config:disable-in-band=true

exec ovn-controller --verbose unix:/var/run/openvswitch/db.sock
