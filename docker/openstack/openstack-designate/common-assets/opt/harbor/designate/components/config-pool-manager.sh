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
echo "${OS_DISTRO}: Configuring pool-manager"
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
                    DESIGNATE_POOL_ID


################################################################################
# Number of Pool Manager worker processes to spawn
crudini --set ${DESIGNATE_CONFIG_FILE} service:pool_manager workers "${API_WORKERS}"
crudini --set ${DESIGNATE_CONFIG_FILE} service:pool_manager threads "1000"

# The ID of the pool managed by this instance of the Pool Manager
crudini --set ${DESIGNATE_CONFIG_FILE} service:pool_manager pool_id "${DESIGNATE_POOL_ID}"

# The percentage of servers requiring a successful update for a domain change
# to be considered active
crudini --set ${DESIGNATE_CONFIG_FILE} service:pool_manager threshold_percentage "100"

crudini --set ${DESIGNATE_CONFIG_FILE} service:pool_manager poll_timeout "30"
crudini --set ${DESIGNATE_CONFIG_FILE} service:pool_manager poll_retry_interval "15"
crudini --set ${DESIGNATE_CONFIG_FILE} service:pool_manager poll_max_retries "10"
crudini --set ${DESIGNATE_CONFIG_FILE} service:pool_manager poll_delay "5"

crudini --set ${DESIGNATE_CONFIG_FILE} service:pool_manager enable_recovery_timer "True"
crudini --set ${DESIGNATE_CONFIG_FILE} service:pool_manager periodic_recovery_interval "120"

crudini --set ${DESIGNATE_CONFIG_FILE} service:pool_manager enable_sync_timer "True"
crudini --set ${DESIGNATE_CONFIG_FILE} service:pool_manager periodic_sync_interval "1800"

# Zones Updated within last N seconds will be syncd. Use None to sync all zones
# crudini --set ${DESIGNATE_CONFIG_FILE} service:pool_manager periodic_sync_seconds "None"
crudini --set ${DESIGNATE_CONFIG_FILE} service:pool_manager periodic_sync_max_attempts "3"
crudini --set ${DESIGNATE_CONFIG_FILE} service:pool_manager periodic_sync_retry_interval "30"

# The cache driver to use
crudini --set ${DESIGNATE_CONFIG_FILE} service:pool_manager cache_driver "memcache"
