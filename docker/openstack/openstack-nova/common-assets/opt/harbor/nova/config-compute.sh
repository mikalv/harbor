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
echo "${OS_DISTRO}: Configuring cinder"
################################################################################
. /etc/os-container.env
. /opt/harbor/service-hosts.sh
. /opt/harbor/harbor-common.sh
. /opt/harbor/nova/vars.sh


################################################################################
check_required_vars NOVA_CONFIG_FILE \
                    OS_DOMAIN


################################################################################
crudini --set ${NOVA_CONFIG_FILE} DEFAULT instance_name_template "instance-%08x"


################################################################################
crudini --set ${NOVA_CONFIG_FILE} DEFAULT force_config_drive "False"
crudini --set ${NOVA_CONFIG_FILE} DEFAULT allow_resize_to_same_host "True"
crudini --set ${NOVA_CONFIG_FILE} DEFAULT default_ephemeral_format "ext4"


################################################################################
crudini --set ${NOVA_CONFIG_FILE} DEFAULT graceful_shutdown_timeout "5"


################################################################################
crudini --set ${NOVA_CONFIG_FILE} DEFAULT instances_path "/var/lib/nova"
