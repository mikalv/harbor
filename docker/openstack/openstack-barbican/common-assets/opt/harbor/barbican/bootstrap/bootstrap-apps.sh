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
echo "${OS_DISTRO}: Bootstrapping apps"
################################################################################
. /etc/os-container.env
. /opt/harbor/service-hosts.sh
. /opt/harbor/harbor-common.sh
. /opt/harbor/barbican/vars.sh


################################################################################
check_required_vars BARBICAN_CONFIG_FILE


echo "${OS_DISTRO}: Imporing base package metadata"
################################################################################
su -s /bin/sh -c "barbican-manage --config-file ${BARBICAN_CONFIG_FILE} import-package /opt/stack/barbican/meta/io.barbican" barbican

APPS_ROOT_DIR="/opt/barbican-apps"
echo "${OS_DISTRO}: Imporing packages"
################################################################################
for APP in $(ls ${APPS_ROOT_DIR}); do
  echo "${OS_DISTRO}: Imporing ${APP} package"
  ##############################################################################
  su -s /bin/sh -c "barbican-manage --config-file ${BARBICAN_CONFIG_FILE} import-package ${APPS_ROOT_DIR}/${APP}" barbican
done
