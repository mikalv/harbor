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
echo "${OS_DISTRO}: Launching tgtd-config"
################################################################################
source /etc/sysconfig/tgtd
# see bz 848942. workaround for a race for now.
/bin/sleep 5
# Put tgtd into "offline" state until all the targets are configured.
# We don't want initiators to (re)connect and fail the connection
# if it's not ready.
/usr/sbin/tgtadm --op update --mode sys --name State -v offline
# Configure the targets.
/usr/sbin/tgt-admin -e -c $TGTD_CONFIG
# Put tgtd into "ready" state.
/usr/sbin/tgtadm --op update --mode sys --name State -v ready
# Update configuration for targets. Only targets which
# are not in use will be updated.
/usr/sbin/tgt-admin --update ALL -c $TGTD_CONFIG
