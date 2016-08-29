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
echo "${OS_DISTRO}: Starting Memcached Container"
################################################################################
touch /etc/os-container.env
source /etc/os-container.env
source /opt/harbor/harbor-vars.sh
source /opt/harbor/service-hosts.sh
source /opt/harbor/harbor-common.sh


################################################################################
check_required_vars OS_DOMAIN \
                    DEVICE \
                    PORT


################################################################################
MEMCACHED_IP="$(ip -f inet -o addr show ${DEVICE}|cut -d\  -f 7 | cut -d/ -f 1)"


echo "${OS_DISTRO}: Launching Memcached @ ${MEMCACHED_IP}:${PORT}"
################################################################################
exec su -s /bin/sh -c "exec memcached -p ${PORT} -U ${PORT} -l ${MEMCACHED_IP}" memcached
