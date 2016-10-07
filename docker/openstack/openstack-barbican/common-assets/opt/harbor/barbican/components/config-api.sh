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
echo "${OS_DISTRO}: Configuring api"
################################################################################
. /etc/os-container.env
. /opt/harbor/service-hosts.sh
. /opt/harbor/harbor-common.sh
. /opt/harbor/barbican/vars.sh
PROC_CORES=$(grep -c ^processor /proc/cpuinfo)
: ${API_WORKERS:="$(( ( $PROC_CORES + 1 ) / 2))"}

################################################################################
check_required_vars BARBICAN_CONFIG_FILE \
                    OS_DOMAIN \
                    BARBICAN_API_SVC_PORT \
                    MY_IP \
                    API_WORKERS


echo "${OS_DISTRO}: Configuring worker params"
################################################################################
echo "${OS_DISTRO}:    Workers: ${API_WORKERS}"
echo "${OS_DISTRO}:    Port: ${BARBICAN_API_SVC_PORT}"
echo "${OS_DISTRO}:    Listen: 127.0.0.1"
crudini --set ${BARBICAN_CONFIG_FILE} DEFAULT bind_port "${BARBICAN_API_SVC_PORT}"
crudini --set ${BARBICAN_CONFIG_FILE} barbican api_workers "${API_WORKERS}"
crudini --set ${BARBICAN_CONFIG_FILE} DEFAULT bind_host "127.0.0.1"
