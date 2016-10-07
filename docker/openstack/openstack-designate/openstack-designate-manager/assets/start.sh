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
. /opt/harbor/service-hosts.sh
. /opt/harbor/harbor-common.sh
. /opt/harbor/designate/vars.sh


echo "${OS_DISTRO}: Testing service dependancies"
################################################################################
/usr/bin/mysql-test


echo "${OS_DISTRO}: Config Starting"
################################################################################
/opt/harbor/config-designate.sh


if ! [ $OS_MANAGEMENT_ACTION == "bootstrap" ]; then
  echo "${OS_DISTRO}: Managing database"
  ##############################################################################
  /opt/harbor/designate/manage/bootstrap-database.sh
  /opt/harbor/designate/manage/bootstrap-database-pools.sh


  echo "${OS_DISTRO}: Managing User"
  ##############################################################################
  /opt/harbor/designate/manage/manage-keystone-user.sh


  echo "${OS_DISTRO}: Managing Service"
  ##############################################################################
  /opt/harbor/designate/manage/manage-keystone-service.sh


  echo "${OS_DISTRO}: Managing Domain"
  ##############################################################################
  /opt/harbor/designate/manage/bootstrap-designate-domain.sh


  echo "${OS_DISTRO}: Finished management"
  ##############################################################################
  tail -f /dev/null
else
  tail -f /dev/null
  echo "${OS_DISTRO}: Bootrapping apps"
  ##############################################################################
  /opt/harbor/designate/bootstrap/bootstrap-apps.sh


  echo "${OS_DISTRO}: Finished management"
  ##############################################################################
  tail -f /dev/null
fi
