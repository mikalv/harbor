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
. /opt/harbor/mistral/vars.sh
. /opt/harbor/mistral/manage/env-keystone-admin-auth.sh


################################################################################
check_required_vars OS_DOMAIN \
                    AUTH_MISTRAL_KEYSTONE_TRUSTEE_REGION \
                    AUTH_MISTRAL_KEYSTONE_TRUSTEE_DOMAIN \
                    AUTH_MISTRAL_KEYSTONE_TRUSTEE_PROJECT_DOMAIN \
                    AUTH_MISTRAL_KEYSTONE_TRUSTEE_PROJECT \
                    AUTH_MISTRAL_KEYSTONE_TRUSTEE_PROJECT_USER_ROLE \
                    AUTH_MISTRAL_KEYSTONE_TRUSTEE_USER \
                    AUTH_MISTRAL_KEYSTONE_TRUSTEE_PASSWORD


################################################################################
AUTH_MISTRAL_KEYSTONE_TRUSTEE_DOMAIN_ID=$(openstack domain create --or-show --enable -f value -c id \
    --description="Service Domain for ${OS_DOMAIN}/${AUTH_MISTRAL_KEYSTONE_TRUSTEE_REGION}" \
    "${AUTH_MISTRAL_KEYSTONE_TRUSTEE_PROJECT_DOMAIN}")
openstack domain show "${AUTH_MISTRAL_KEYSTONE_TRUSTEE_DOMAIN_ID}"


################################################################################
AUTH_MISTRAL_KEYSTONE_TRUSTEE_PROJECT_ID=$(openstack project create --or-show --enable -f value -c id \
    --domain="${AUTH_MISTRAL_KEYSTONE_TRUSTEE_DOMAIN_ID}" \
    --description="Service Project for ${OS_DOMAIN}/${AUTH_MISTRAL_KEYSTONE_TRUSTEE_REGION}" \
    "${AUTH_MISTRAL_KEYSTONE_TRUSTEE_PROJECT}")
openstack project show "${AUTH_MISTRAL_KEYSTONE_TRUSTEE_PROJECT_ID}"


################################################################################
AUTH_MISTRAL_KEYSTONE_TRUSTEE_USER_ID=$(openstack user create --or-show --enable -f value -c id \
    --domain="${AUTH_MISTRAL_KEYSTONE_TRUSTEE_DOMAIN_ID}" \
    --project-domain "${AUTH_MISTRAL_KEYSTONE_TRUSTEE_PROJECT_DOMAIN}" \
    --project="${AUTH_MISTRAL_KEYSTONE_TRUSTEE_PROJECT_ID}" \
    --description "Service User for ${OS_DOMAIN}/${AUTH_MISTRAL_KEYSTONE_TRUSTEE_REGION}/mistral" \
    --email="support@${OS_DOMAIN}" \
    --password="${AUTH_MISTRAL_KEYSTONE_TRUSTEE_PASSWORD}" \
    "${AUTH_MISTRAL_KEYSTONE_TRUSTEE_USER}")
openstack user show "${AUTH_MISTRAL_KEYSTONE_TRUSTEE_USER_ID}"



################################################################################
openstack role add \
          --user="${AUTH_MISTRAL_KEYSTONE_TRUSTEE_USER_ID}" \
          --user-domain="${AUTH_MISTRAL_KEYSTONE_TRUSTEE_DOMAIN_ID}" \
          --domain="${AUTH_MISTRAL_KEYSTONE_TRUSTEE_DOMAIN_ID}" \
          "${AUTH_MISTRAL_KEYSTONE_TRUSTEE_PROJECT_USER_ROLE}"

openstack role assignment list \
          --domain="${AUTH_MISTRAL_KEYSTONE_TRUSTEE_DOMAIN_ID}" \
          --role="${AUTH_MISTRAL_KEYSTONE_TRUSTEE_PROJECT_USER_ROLE}" \
          --user-domain="${AUTH_MISTRAL_KEYSTONE_TRUSTEE_DOMAIN_ID}" \
          --user="${AUTH_MISTRAL_KEYSTONE_TRUSTEE_USER_ID}"


################################################################################
openstack role add \
          --user="${AUTH_MISTRAL_KEYSTONE_TRUSTEE_USER_ID}" \
          --user-domain="${AUTH_MISTRAL_KEYSTONE_TRUSTEE_DOMAIN}" \
          --project-domain="${AUTH_MISTRAL_KEYSTONE_TRUSTEE_PROJECT_DOMAIN}" \
          --project="${AUTH_MISTRAL_KEYSTONE_TRUSTEE_PROJECT_ID}" \
          "${AUTH_MISTRAL_KEYSTONE_TRUSTEE_PROJECT_USER_ROLE}"

openstack role assignment list \
          --project-domain="${AUTH_MISTRAL_KEYSTONE_TRUSTEE_PROJECT_DOMAIN}" \
          --project="${AUTH_MISTRAL_KEYSTONE_TRUSTEE_PROJECT_ID}" \
          --role="${AUTH_MISTRAL_KEYSTONE_TRUSTEE_PROJECT_USER_ROLE}" \
          --user-domain="${AUTH_MISTRAL_KEYSTONE_TRUSTEE_DOMAIN}" \
          --user="${AUTH_MISTRAL_KEYSTONE_TRUSTEE_USER_ID}"
