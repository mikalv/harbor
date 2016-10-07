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
echo "${OS_DISTRO}: Managing designate domain and user"
################################################################################
. /etc/os-container.env
. /opt/harbor/service-hosts.sh
. /opt/harbor/harbor-common.sh
. /opt/harbor/designate/vars.sh
. /opt/harbor/designate/manage/env-keystone-admin-auth.sh

################################################################################
check_required_vars OS_DOMAIN \
                    AUTH_DESIGNATE_KEYSTONE_REGION \
                    AUTH_DESIGNATE_KEYSTONE_DOMAIN \
                    AUTH_DESIGNATE_KEYSTONE_PROJECT_DOMAIN \
                    AUTH_DESIGNATE_KEYSTONE_PROJECT \
                    AUTH_DESIGNATE_KEYSTONE_PROJECT_USER_ROLE \
                    AUTH_DESIGNATE_KEYSTONE_USER \
                    AUTH_DESIGNATE_KEYSTONE_PASSWORD \
                    DESIGNATE_ADMIN_PROJECT \
                    DESIGNATE_ADMIN_DOMAIN \
                    DESIGNATE_ADMIN_ROLE


################################################################################
DESIGNATE_DOMAIN_ID=$(openstack domain create --or-show --enable -f value -c id \
    --description="Service Domain for ${OS_DOMAIN}/${AUTH_DESIGNATE_KEYSTONE_REGION}" \
    "${DESIGNATE_ADMIN_DOMAIN}")
openstack domain show "${DESIGNATE_DOMAIN_ID}"


################################################################################
AUTH_DESIGNATE_PROJECT_ID=$(openstack project create --or-show --enable -f value -c id \
    --domain="${DESIGNATE_DOMAIN_ID}" \
    --description="Service Project for ${OS_DOMAIN}/${AUTH_DESIGNATE_KEYSTONE_REGION}" \
    "${DESIGNATE_ADMIN_PROJECT}")
openstack project show "${AUTH_DESIGNATE_PROJECT_ID}"


################################################################################
DESIGNATE_KEYSTONE_USER_ID=$(openstack user create --or-show --enable -f value -c id \
    --domain="${DESIGNATE_DOMAIN_ID}" \
    --project-domain="${DESIGNATE_DOMAIN_ID}" \
    --project="${AUTH_DESIGNATE_PROJECT_ID}" \
    --description "Service User for ${DESIGNATE_ADMIN_DOMAIN}/${AUTH_DESIGNATE_KEYSTONE_REGION}/designate" \
    --email="support@${OS_DOMAIN}" \
    --password="${AUTH_DESIGNATE_KEYSTONE_PASSWORD}" \
    "${AUTH_DESIGNATE_KEYSTONE_USER}")
openstack user show "${DESIGNATE_KEYSTONE_USER_ID}"


################################################################################
openstack role add \
          --user="${DESIGNATE_KEYSTONE_USER_ID}" \
          --user-domain="${DESIGNATE_DOMAIN_ID}" \
          --domain="${DESIGNATE_DOMAIN_ID}" \
          "${AUTH_DESIGNATE_KEYSTONE_PROJECT_USER_ROLE}"

openstack role assignment list \
          --domain="${DESIGNATE_DOMAIN_ID}" \
          --role="${AUTH_DESIGNATE_KEYSTONE_PROJECT_USER_ROLE}" \
          --user-domain="${DESIGNATE_DOMAIN_ID}" \
          --user="${AUTH_DESIGNATE_KEYSTONE_USER_ID}"


################################################################################
for ROLE in ${AUTH_DESIGNATE_KEYSTONE_PROJECT_USER_ROLE} ${DESIGNATE_ADMIN_ROLE}; do
  openstack role add \
          --user="${DESIGNATE_KEYSTONE_USER_ID}" \
          --user-domain="${DESIGNATE_DOMAIN_ID}" \
          --project-domain="${DESIGNATE_DOMAIN_ID}" \
          --project="${AUTH_DESIGNATE_PROJECT_ID}" \
          "${ROLE}"

  openstack role assignment list \
          --project-domain="${DESIGNATE_DOMAIN_ID}" \
          --project="${AUTH_DESIGNATE_PROJECT_ID}" \
          --role="${ROLE}" \
          --user-domain="${DESIGNATE_DOMAIN_ID}" \
          --user="${AUTH_DESIGNATE_KEYSTONE_USER_ID}"
done
