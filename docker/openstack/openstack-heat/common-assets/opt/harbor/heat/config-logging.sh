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
echo "${OS_DISTRO}: Configuring logging"
################################################################################
. /etc/os-container.env
. /opt/harbor/service-hosts.sh
. /opt/harbor/harbor-common.sh
. /opt/harbor/heat/vars.sh


################################################################################
check_required_vars HEAT_CONFIG_FILE


################################################################################
crudini --set ${HEAT_CONFIG_FILE} DEFAULT use_syslog "False"
crudini --set ${HEAT_CONFIG_FILE} DEFAULT logging_exception_prefix "%(color)s%(asctime)s.%(msecs)03d TRACE %(name)s %(instance)s"
crudini --set ${HEAT_CONFIG_FILE} DEFAULT logging_debug_format_suffix "from (pid=%(process)d) %(funcName)s %(pathname)s:%(lineno)d"
crudini --set ${HEAT_CONFIG_FILE} DEFAULT logging_default_format_string "%(asctime)s.%(msecs)03d %(color)s%(levelname)s %(name)s [-%(color)s] %(instance)s%(color)s%(message)s"
crudini --set ${HEAT_CONFIG_FILE} DEFAULT logging_context_format_string "%(asctime)s.%(msecs)03d %(color)s%(levelname)s %(name)s [%(request_id)s %(user_name)s %(project_id)s%(color)s] %(instance)s%(color)s%(message)s"
