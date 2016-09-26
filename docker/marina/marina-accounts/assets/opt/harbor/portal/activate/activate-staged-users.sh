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
: ${OS_DISTRO:="HarborOS: Auth"}
echo "${OS_DISTRO}: Starting email config"
################################################################################
. /etc/os-container.env
. /opt/harbor/service-hosts.sh
. /opt/harbor/harbor-common.sh
. /opt/harbor/portal/vars.sh

export IPA_REALM=$(cat /etc/ipa/default.conf | grep "realm" | awk '{print $3}')
################################################################################
echo "${OS_DISTRO}: ${OPENSTACK_COMPONENT}: ${OPENSTACK_SUBCOMPONENT}: Checking Enviornment Variables"
################################################################################
check_required_vars IPA_REALM AUTH_FREEIPA_HOST_ADMIN_PASSWORD AUTH_FREEIPA_HOST_ADMIN_USER
dump_vars


################################################################################
echo "${OS_DISTRO}: ${OPENSTACK_COMPONENT}: ${OPENSTACK_SUBCOMPONENT}: Sourcing Admin Credentials and ckecking we can get a token"
################################################################################
. /opt/harbor/portal/manage/env-keystone-auth.sh

################################################################################
echo "${OS_DISTRO}: ${OPENSTACK_COMPONENT}: ${OPENSTACK_SUBCOMPONENT}: kinit as the admin user"
################################################################################
echo "${AUTH_FREEIPA_HOST_ADMIN_PASSWORD}" | kinit ${AUTH_FREEIPA_HOST_ADMIN_USER}




################################################################################
echo "${OS_DISTRO}: ${OPENSTACK_COMPONENT}: ${OPENSTACK_SUBCOMPONENT}: Provisioning Accounts"
################################################################################
ipa stageuser-find --pkey-only | grep "^  User login: " | awk '{print $NF}' | while read STAGE_USER; do
    NEW_USERNAME=sqdqwd
  NEW_USERNAME=${STAGE_USER}
  echo "User: ${NEW_USERNAME}"
  USER_EMAIL="$(ipa stageuser-show $NEW_USERNAME | grep "^  Email address: " | head -n1 | awk '{print $NF}')"
  echo "Email: ${USER_EMAIL}"

  # Create a group for our user to own - using groups as a direct equiv of keystone v2 tenants
  ipa group-add --desc="Keystone Federation User Group for ${NEW_USERNAME}" "keystone-${NEW_USERNAME}"
  openstack group show --domain ${IPA_REALM} "keystone-${NEW_USERNAME}"

  # Now we need to create a keystone project, and give our user access to it via their group
  KEYSTONE_PROJECT=${NEW_USERNAME}
  openstack project create --or-show --domain ${IPA_REALM} --description "${OS_DOMAIN} project for ${NEW_USERNAME}" ${KEYSTONE_PROJECT}
  openstack role add --project-domain ${IPA_REALM} --project ${KEYSTONE_PROJECT} --group-domain ${IPA_REALM} --group "keystone-${NEW_USERNAME}" Member

  # Now the env is prepped for our user lets activate them, remove them from the ipa-users group and add them to their own group
  ipa stageuser-activate ${NEW_USERNAME}
  ipa group-remove-member "ipausers" --users "${NEW_USERNAME}"
  ipa group-add-member "keystone-${NEW_USERNAME}" --users "${NEW_USERNAME}"

  EMAIL_UUID=$(uuidgen)
  # Tell the user the good news, that they can get going!
  sed "s/{{ USER }}/${NEW_USERNAME}/" /srv/mail/blank-slate/conv.html > /tmp/welcome-${EMAIL_UUID}
  mutt -e "set sendmail=/usr/sbin/ssmtp" \
  -e "set content_type=text/html" \
  -e "set use_from=yes" \
  -e "set from=${PORTAL_DEFAULT_FROM_EMAIL}" \
  -e "set realname=\"${OS_DOMAIN}\"" \
  ${USER_EMAIL} -s "Welcome to ${OS_DOMAIN}" < /tmp/welcome-${EMAIL_UUID}
  rm -f /tmp/welcome-${EMAIL_UUID}
done
