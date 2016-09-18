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
echo "${OS_DISTRO}: Managing keystone users"
################################################################################
. /etc/os-container.env
. /opt/harbor/service-hosts.sh
. /opt/harbor/harbor-common.sh
. /opt/harbor/raven/vars.sh
. /opt/harbor/raven/manage/env-keystone-admin-auth.sh


################################################################################
AUTH_RAVEN_KEYSTONE_PROJECT_ID="$(openstack project show ${AUTH_RAVEN_KEYSTONE_PROJECT} -f value -c id)"
check_required_vars OS_DOMAIN \
                    AUTH_RAVEN_KEYSTONE_PROJECT_ID


################################################################################
neutron quota-update \
        --loadbalancer 100 \
        --listener 100 \
        --pool 100 \
        --security-group-rule 1000 \
        --security-group 100 \
        --floatingip 100 \
        --router 10 \
        --port -1 \
        --subnet 100 \
        --network 100 \
        --tenant-id ${AUTH_RAVEN_KEYSTONE_PROJECT_ID}
