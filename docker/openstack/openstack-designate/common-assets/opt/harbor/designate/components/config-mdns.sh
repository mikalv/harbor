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
echo "${OS_DISTRO}: Configuring mdns"
################################################################################
. /etc/os-container.env
. /opt/harbor/service-hosts.sh
. /opt/harbor/harbor-common.sh
. /opt/harbor/designate/vars.sh
PROC_CORES=$(grep -c ^processor /proc/cpuinfo)
: ${API_WORKERS:="$(( ( $PROC_CORES + 1 ) / 2))"}


################################################################################
check_required_vars DESIGNATE_CONFIG_FILE \
                    OS_DOMAIN \
                    MY_IP \
                    API_WORKERS \
                    DESIGNATE_MDNS_ALL_TCP


################################################################################
crudini --set ${DESIGNATE_CONFIG_FILE} service:mdns workers "${API_WORKERS}"
crudini --set ${DESIGNATE_CONFIG_FILE} service:mdns threads "1000"
crudini --set ${DESIGNATE_CONFIG_FILE} service:mdns listen "${MY_IP}:5354"
crudini --set ${DESIGNATE_CONFIG_FILE} service:mdns tcp_backlog "100"
crudini --set ${DESIGNATE_CONFIG_FILE} service:mdns tcp_recv_timeout "0.5"
crudini --set ${DESIGNATE_CONFIG_FILE} service:mdns query_enforce_tsig "False"
crudini --set ${DESIGNATE_CONFIG_FILE} service:mdns all_tcp "${DESIGNATE_MDNS_ALL_TCP}"
crudini --set ${DESIGNATE_CONFIG_FILE} service:mdns max_message_size "65535"
