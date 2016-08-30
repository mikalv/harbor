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
echo "${OS_DISTRO}: Launching OVN Northd Container"
################################################################################
. /etc/os-container.env
. /opt/harbor/service-hosts.sh
. /opt/harbor/harbor-common.sh


################################################################################
check_required_vars OS_DOMAIN \
                    OVN_NB_DB_SERVICE_HOST_SVC \
                    OVN_SB_DB_SERVICE_HOST_SVC


################################################################################
OVS_NB_DB_IP=$(dig +short ${OVN_NB_DB_SERVICE_HOST_SVC} | awk '{ print ; exit }')
OVS_SB_DB_IP=$(dig +short ${OVN_SB_DB_SERVICE_HOST_SVC} | awk '{ print ; exit }')
check_required_vars OVS_SB_DB_IP \
                    OVS_NB_DB_IP


echo "${OS_DISTRO}: Launching Container Application"
################################################################################
echo "${OS_DISTRO}: Connecting to NB database @ tcp:${OVS_NB_DB_IP}:6641"
echo "${OS_DISTRO}: Connecting to SB database @ tcp:${OVS_SB_DB_IP}:6642"
exec ovn-northd \
      --log-file="/dev/null" \
      --ovnnb-db=tcp:${OVS_NB_DB_IP}:6641 \
      --ovnsb-db=tcp:${OVS_SB_DB_IP}:6642
