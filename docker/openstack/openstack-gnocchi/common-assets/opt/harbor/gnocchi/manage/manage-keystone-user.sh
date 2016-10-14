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
. /opt/harbor/gnocchi/vars.sh
. /opt/harbor/gnocchi/manage/env-keystone-admin-auth.sh


################################################################################
check_required_vars OS_DOMAIN \
                    AUTH_GNOCCHI_KEYSTONE_REGION \
                    AUTH_GNOCCHI_KEYSTONE_DOMAIN \
                    AUTH_GNOCCHI_KEYSTONE_PROJECT_DOMAIN \
                    AUTH_GNOCCHI_KEYSTONE_PROJECT \
                    AUTH_GNOCCHI_KEYSTONE_PROJECT_USER_ROLE \
                    AUTH_GNOCCHI_KEYSTONE_USER \
                    AUTH_GNOCCHI_KEYSTONE_PASSWORD


################################################################################
AUTH_GNOCCHI_KEYSTONE_PROJECT_ID=$(openstack project create --or-show --enable -f value -c id \
    --domain="${AUTH_GNOCCHI_KEYSTONE_PROJECT_DOMAIN}" \
    --description="Service Project for ${OS_DOMAIN}/${AUTH_GNOCCHI_KEYSTONE_REGION}" \
    "${AUTH_GNOCCHI_KEYSTONE_PROJECT}")
openstack project show "${AUTH_GNOCCHI_KEYSTONE_PROJECT_ID}"


################################################################################
AUTH_GNOCCHI_KEYSTONE_USER_ID=$(openstack user create --or-show --enable -f value -c id \
    --domain="${AUTH_GNOCCHI_KEYSTONE_DOMAIN}" \
    --project-domain "${AUTH_GNOCCHI_KEYSTONE_PROJECT_DOMAIN}" \
    --project="${AUTH_GNOCCHI_KEYSTONE_PROJECT_ID}" \
    --description "Service User for ${OS_DOMAIN}/${AUTH_GNOCCHI_KEYSTONE_REGION}/gnocchi" \
    --email="support@${OS_DOMAIN}" \
    --password="${AUTH_GNOCCHI_KEYSTONE_PASSWORD}" \
    "${AUTH_GNOCCHI_KEYSTONE_USER}")
openstack user show "${AUTH_GNOCCHI_KEYSTONE_USER_ID}"



################################################################################
openstack role add \
          --user="${AUTH_GNOCCHI_KEYSTONE_USER_ID}" \
          --user-domain="${AUTH_GNOCCHI_KEYSTONE_DOMAIN}" \
          --project-domain="${AUTH_GNOCCHI_KEYSTONE_PROJECT_DOMAIN}" \
          --project="${AUTH_GNOCCHI_KEYSTONE_PROJECT_ID}" \
          "${AUTH_GNOCCHI_KEYSTONE_PROJECT_USER_ROLE}"

openstack role assignment list \
          --project-domain="${AUTH_GNOCCHI_KEYSTONE_PROJECT_DOMAIN}" \
          --project="${AUTH_GNOCCHI_KEYSTONE_PROJECT_ID}" \
          --role="${AUTH_GNOCCHI_KEYSTONE_PROJECT_USER_ROLE}" \
          --user-domain="${AUTH_GNOCCHI_KEYSTONE_DOMAIN}" \
          --user="${AUTH_GNOCCHI_KEYSTONE_USER_ID}"


################################################################################
/opt/harbor/gnocchi/manage/env-keystone-auth.sh
