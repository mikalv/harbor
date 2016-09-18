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
echo "${OS_DISTRO}: Configuring Cinder volume"
################################################################################
. /etc/os-container.env
. /opt/harbor/service-hosts.sh
. /opt/harbor/harbor-common.sh
. /opt/harbor/cinder/vars.sh
. /opt/harbor/cinder/manage/env-keystone-admin-auth.sh


################################################################################
check_required_vars AUTH_CINDER_KEYSTONE_PROJECT
AUTH_CINDER_KEYSTONE_PROJECT_ID=$(openstack project show -f value -c id ${AUTH_CINDER_KEYSTONE_PROJECT})
check_required_vars AUTH_CINDER_KEYSTONE_PROJECT_ID


################################################################################
cinder quota-usage $AUTH_CINDER_KEYSTONE_PROJECT_ID
cinder quota-update --volumes 100 $AUTH_CINDER_KEYSTONE_PROJECT_ID
cinder quota-update --snapshots 100 $AUTH_CINDER_KEYSTONE_PROJECT_ID
