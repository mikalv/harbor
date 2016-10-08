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
. /opt/harbor/barbican/vars.sh
. /opt/harbor/barbican/manage/env-keystone-admin-auth.sh

################################################################################
check_required_vars OS_DOMAIN \
                    AUTH_BARBICAN_KEYSTONE_SERVICE_REGION \
                    AUTH_BARBICAN_KEYSTONE_SERVICE_DOMAIN \
                    AUTH_BARBICAN_KEYSTONE_SERVICE_PROJECT_DOMAIN \
                    AUTH_BARBICAN_KEYSTONE_SERVICE_PROJECT \
                    AUTH_BARBICAN_KEYSTONE_SERVICE_PROJECT_USER_ROLE \
                    AUTH_BARBICAN_KEYSTONE_SERVICE_USER \
                    AUTH_BARBICAN_KEYSTONE_SERVICE_PASSWORD


################################################################################
AUTH_BARBICAN_KEYSTONE_SERVICE_PROJECT_ID=$(openstack project create --or-show --enable -f value -c id \
    --domain="${AUTH_BARBICAN_KEYSTONE_SERVICE_PROJECT_DOMAIN}" \
    --description="Service Project for ${OS_DOMAIN}/${AUTH_BARBICAN_KEYSTONE_SERVICE_REGION}" \
    "${AUTH_BARBICAN_KEYSTONE_SERVICE_PROJECT}")
openstack project show "${AUTH_BARBICAN_KEYSTONE_SERVICE_PROJECT_ID}"


################################################################################
AUTH_BARBICAN_KEYSTONE_SERVICE_USER_ID=$(openstack user create --or-show --enable -f value -c id \
    --domain="${AUTH_BARBICAN_KEYSTONE_SERVICE_DOMAIN}" \
    --project-domain "${AUTH_BARBICAN_KEYSTONE_SERVICE_PROJECT_DOMAIN}" \
    --project="${AUTH_BARBICAN_KEYSTONE_SERVICE_PROJECT_ID}" \
    --description "Service User for ${OS_DOMAIN}/${AUTH_BARBICAN_KEYSTONE_SERVICE_REGION}/barbican" \
    --email="support@${OS_DOMAIN}" \
    --password="${AUTH_BARBICAN_KEYSTONE_SERVICE_PASSWORD}" \
    "${AUTH_BARBICAN_KEYSTONE_SERVICE_USER}")
openstack user show "${AUTH_BARBICAN_KEYSTONE_SERVICE_USER_ID}"



################################################################################
openstack role create --or-show "${AUTH_BARBICAN_KEYSTONE_SERVICE_PROJECT_USER_ROLE}"

openstack role add \
          --user="${AUTH_BARBICAN_KEYSTONE_SERVICE_USER_ID}" \
          --user-domain="${AUTH_BARBICAN_KEYSTONE_SERVICE_DOMAIN}" \
          --project-domain="${AUTH_BARBICAN_KEYSTONE_SERVICE_PROJECT_DOMAIN}" \
          --project="${AUTH_BARBICAN_KEYSTONE_SERVICE_PROJECT_ID}" \
          "${AUTH_BARBICAN_KEYSTONE_SERVICE_PROJECT_USER_ROLE}"

openstack role assignment list \
          --project-domain="${AUTH_BARBICAN_KEYSTONE_SERVICE_PROJECT_DOMAIN}" \
          --project="${AUTH_BARBICAN_KEYSTONE_SERVICE_PROJECT_ID}" \
          --role="${AUTH_BARBICAN_KEYSTONE_SERVICE_PROJECT_USER_ROLE}" \
          --user-domain="${AUTH_BARBICAN_KEYSTONE_SERVICE_DOMAIN}" \
          --user="${AUTH_BARBICAN_KEYSTONE_SERVICE_USER_ID}"
