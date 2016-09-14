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
echo "${OS_DISTRO}: Launching"
################################################################################
. /etc/os-container.env
. /opt/harbor/service-hosts.sh
. /opt/harbor/harbor-common.sh
. /opt/harbor/keystone/vars.sh


echo "${OS_DISTRO}: Testing environment"
################################################################################
/usr/bin/mysql-test


echo "${OS_DISTRO}: Configuring database"
################################################################################
/opt/harbor/keystone/config-database.sh


if ! [ $OS_MANAGEMENT_ACTION == "bootstrap" ]; then
  echo "${OS_DISTRO}: Managing database"
  ################################################################################
  /opt/harbor/keystone/manage/bootstrap-database.sh


  echo "${OS_DISTRO}: Managing tokens"
  ################################################################################
  /opt/harbor/keystone/manage/manage-tokens.sh


  echo "${OS_DISTRO}: Finished management"
  ################################################################################
else
  echo "${OS_DISTRO}: Testing environment"
  ################################################################################
  /opt/harbor/keystone/manage/env-keystone-admin-auth.sh


  echo "${OS_DISTRO}: Managing users"
  ################################################################################
  /opt/harbor/keystone/bootstrap/bootstrap-keystone-users.sh


  echo "${OS_DISTRO}: Managing domains"
  ################################################################################
  /opt/harbor/keystone/bootstrap/bootstrap-keystone-domains.sh


  echo "${OS_DISTRO}: Managing federation"
  ################################################################################
  /opt/harbor/keystone/bootstrap/bootstrap-keystone-fed.sh


  echo "${OS_DISTRO}: Finished management"
  ################################################################################
  tail -f /dev/null
fi
