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
. /opt/harbor/designate/vars.sh


################################################################################
check_required_vars DESIGNATE_CONFIG_FILE


################################################################################
crudini --set ${DESIGNATE_CONFIG_FILE} DEFAULT use_syslog "False"
crudini --set ${DESIGNATE_CONFIG_FILE} DEFAULT logging_exception_prefix "%(color)s%(asctime)s.%(msecs)03d TRACE %(name)s [01;35m%(instance)s[00m"
crudini --set ${DESIGNATE_CONFIG_FILE} DEFAULT logging_debug_format_suffix "[00;33mfrom (pid=%(process)d) %(funcName)s %(pathname)s:%(lineno)d[00m"
crudini --set ${DESIGNATE_CONFIG_FILE} DEFAULT logging_default_format_string "%(asctime)s.%(msecs)03d %(color)s%(levelname)s %(name)s [[00;36m-%(color)s] [01;35m%(instance)s%(color)s%(message)s[00m"
crudini --set ${DESIGNATE_CONFIG_FILE} DEFAULT logging_context_format_string "%(asctime)s.%(msecs)03d %(color)s%(levelname)s %(name)s [[01;36m%(request_id)s [00;36m%(user_identity)s%(color)s] [01;35m%(instance)s%(color)s%(message)s[00m"
