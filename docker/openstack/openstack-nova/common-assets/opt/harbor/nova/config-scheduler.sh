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
echo "${OS_DISTRO}: Configuring messaging"
################################################################################
. /etc/os-container.env
. /opt/harbor/service-hosts.sh
. /opt/harbor/harbor-common.sh
. /opt/harbor/nova/vars.sh


################################################################################
check_required_vars NOVA_CONFIG_FILE \
                    OS_DOMAIN \
                    AUTH_MESSAGING_PASS \
                    AUTH_MESSAGING_USER \
                    RABBITMQ_SERVICE_HOST_SVC


################################################################################
crudini --set ${NOVA_CONFIG_FILE} DEFAULT scheduler_driver "filter_scheduler"
crudini --set ${NOVA_CONFIG_FILE} DEFAULT scheduler_default_filters \
"RetryFilter,\
AvailabilityZoneFilter,\
RamFilter,\
DiskFilter,\
ComputeFilter,\
ComputeCapabilitiesFilter,\
ImagePropertiesFilter,\
ServerGroupAntiAffinityFilter,\
ServerGroupAffinityFilter,\
SameHostFilter,\
DifferentHostFilter"
