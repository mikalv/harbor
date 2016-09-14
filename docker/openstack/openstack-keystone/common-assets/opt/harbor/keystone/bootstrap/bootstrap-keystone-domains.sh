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
echo "${OS_DISTRO}: Bootstrapping ${OS_DOMAIN} domain"
################################################################################
. /etc/os-container.env
. /opt/harbor/service-hosts.sh
. /opt/harbor/harbor-common.sh
. /opt/harbor/keystone/vars.sh
. /opt/harbor/keystone/manage/env-keystone-admin-auth.sh


################################################################################
check_required_vars KEYSTONE_CONFIG_FILE \
                    OS_DOMAIN \
                    FREEIPA_SERVICE_HOST \
                    AUTH_KEYSTONE_LDAP_USER \
                    AUTH_KEYSTONE_LDAP_PASSWORD \
                    KEYSTONE_LDAP_BASE_DN \
                    KEYSTONE_DB_CA


echo "${OS_DISTRO}: Writing domain config"
################################################################################
KEYSTONE_DOMAIN_CONF="/etc/keystone/domains/keystone.${OS_DOMAIN}.conf"
mkdir -p $(dirname ${KEYSTONE_DOMAIN_CONF})
crudini --set ${KEYSTONE_DOMAIN_CONF} identity driver "keystone.identity.backends.ldap.Identity"

################################################################################
crudini --set ${KEYSTONE_DOMAIN_CONF} ldap url "ldaps://${FREEIPA_SERVICE_HOST}"
crudini --set ${KEYSTONE_DOMAIN_CONF} ldap user "uid=${AUTH_KEYSTONE_LDAP_USER},cn=users,cn=accounts,${KEYSTONE_LDAP_BASE_DN}"
crudini --set ${KEYSTONE_DOMAIN_CONF} ldap password "${AUTH_KEYSTONE_LDAP_PASSWORD}"

# Set use_tls to false as ldaps, not start-tls
################################################################################
crudini --set ${KEYSTONE_DOMAIN_CONF} ldap use_tls "False"
crudini --set ${KEYSTONE_DOMAIN_CONF} ldap tls_cacertfile "${KEYSTONE_DB_CA}"

################################################################################
crudini --set ${KEYSTONE_DOMAIN_CONF} ldap suffix "${KEYSTONE_LDAP_BASE_DN}"

################################################################################
crudini --set ${KEYSTONE_DOMAIN_CONF} ldap user_tree_dn "cn=users,cn=accounts,${KEYSTONE_LDAP_BASE_DN}"
crudini --set ${KEYSTONE_DOMAIN_CONF} ldap user_objectclass "person"
crudini --set ${KEYSTONE_DOMAIN_CONF} ldap user_id_attribute "uid"
crudini --set ${KEYSTONE_DOMAIN_CONF} ldap user_name_attribute "uid"
crudini --set ${KEYSTONE_DOMAIN_CONF} ldap user_mail_attribute "mail"
crudini --set ${KEYSTONE_DOMAIN_CONF} ldap user_allow_create "false"
crudini --set ${KEYSTONE_DOMAIN_CONF} ldap user_allow_update "false"
crudini --set ${KEYSTONE_DOMAIN_CONF} ldap user_allow_delete "false"

################################################################################
crudini --set ${KEYSTONE_DOMAIN_CONF} ldap group_tree_dn "cn=groups,cn=accounts,${KEYSTONE_LDAP_BASE_DN}"
crudini --set ${KEYSTONE_DOMAIN_CONF} ldap group_objectclass "groupOfNames"
crudini --set ${KEYSTONE_DOMAIN_CONF} ldap group_id_attribute "cn"
crudini --set ${KEYSTONE_DOMAIN_CONF} ldap group_name_attribute "cn"
crudini --set ${KEYSTONE_DOMAIN_CONF} ldap group_member_attribute "member"
crudini --set ${KEYSTONE_DOMAIN_CONF} ldap group_desc_attribute "description"
crudini --set ${KEYSTONE_DOMAIN_CONF} ldap group_allow_create "false"
crudini --set ${KEYSTONE_DOMAIN_CONF} ldap group_allow_update "false"
crudini --set ${KEYSTONE_DOMAIN_CONF} ldap group_allow_delete "false"

################################################################################
crudini --set ${KEYSTONE_DOMAIN_CONF} ldap user_enabled_attribute "nsAccountLock"
crudini --set ${KEYSTONE_DOMAIN_CONF} ldap user_enabled_default "False"
crudini --set ${KEYSTONE_DOMAIN_CONF} ldap user_enabled_invert "true"

echo "${OS_DISTRO}: Managing domain: ${OS_DOMAIN}"
################################################################################
chown -R keystone:keystone $(dirname ${KEYSTONE_DOMAIN_CONF})
IPA_REALM_DESCRIPTION="${OS_DOMAIN} user domain"
(openstack domain create --description "${IPA_REALM_DESCRIPTION}" ${OS_DOMAIN} && \
keystone-manage --debug --verbose domain_config_upload --domain-name ${OS_DOMAIN} && \
keystone-manage --debug mapping_populate --domain ${OS_DOMAIN} ) || \
  openstack domain show ${OS_DOMAIN}


echo "${OS_DISTRO}: Managing domain admin: ${AUTH_FREEIPA_USER_ADMIN_USER}@${OS_DOMAIN}"
################################################################################
AUTH_FREEIPA_USER_ADMIN_USER_ID=$( openstack user show --domain ${OS_DOMAIN}  ${AUTH_FREEIPA_USER_ADMIN_USER} \
                                        -f value -c id  )
openstack role add \
  --domain ${OS_DOMAIN} \
  --user-domain ${OS_DOMAIN} \
  --user ${AUTH_FREEIPA_USER_ADMIN_USER_ID} \
  "admin"
openstack role add \
  --domain ${OS_DOMAIN} \
  --user-domain ${OS_DOMAIN} \
  --user ${AUTH_FREEIPA_USER_ADMIN_USER_ID} \
  "Member"
