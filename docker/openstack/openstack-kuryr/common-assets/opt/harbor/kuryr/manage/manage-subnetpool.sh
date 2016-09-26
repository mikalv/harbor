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
echo "${OS_DISTRO}: Managing subnet pool"
################################################################################
. /etc/os-container.env
. /opt/harbor/service-hosts.sh
. /opt/harbor/harbor-common.sh
. /opt/harbor/kuryr/vars.sh
. /opt/harbor/kuryr/manage/env-keystone-auth.sh


################################################################################
check_required_vars OS_DOMAIN \
                    KURYR_POOL_PREFIX \
                    KURYR_POOL_PREFIX_LEN \
                    KURYR_POOL_NAME


################################################################################
neutron subnetpool-show ${KURYR_POOL_NAME} || neutron subnetpool-create \
  --default-prefixlen ${KURYR_POOL_PREFIX_LEN} \
  --pool-prefix ${KURYR_POOL_PREFIX} ${KURYR_POOL_NAME}
