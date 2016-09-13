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
echo "${OS_DISTRO}: Bootsrapping domains"
################################################################################
. /etc/os-container.env
. /opt/harbor/service-hosts.sh
. /opt/harbor/harbor-common.sh
. /opt/harbor/keystone/vars.sh


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
mkdir -p /etc/keystone/domains
cat > /etc/keystone/domains/keystone.${OS_DOMAIN}.conf << EOF
[identity]
driver = keystone.identity.backends.ldap.Identity

[ldap]
use_tls=True
tls_cacertfile=${KEYSTONE_DB_CA}
url=ldaps://${FREEIPA_SERVICE_HOST}
user=uid=${AUTH_KEYSTONE_LDAP_USER},cn=users,cn=accounts,${KEYSTONE_LDAP_BASE_DN}
password=${AUTH_KEYSTONE_LDAP_PASSWORD}
suffix=${KEYSTONE_LDAP_BASE_DN}
user_tree_dn=cn=users,cn=accounts,${KEYSTONE_LDAP_BASE_DN}
user_objectclass=person
user_id_attribute=uid
user_name_attribute=uid
user_mail_attribute=mail
user_allow_create=false
user_allow_update=false
user_allow_delete=false

group_tree_dn=cn=groups,cn=accounts,${KEYSTONE_LDAP_BASE_DN}
group_objectclass=groupOfNames
group_id_attribute=cn
group_name_attribute=cn
group_member_attribute=member
group_desc_attribute=description
group_allow_create=false
group_allow_update=false
group_allow_delete=false

user_enabled_attribute=nsAccountLock
user_enabled_default=False
user_enabled_invert=true

EOF
chown -R keystone:keystone /etc/keystone/domains


echo "${OS_DISTRO}: Managing domain for ${OS_DOMAIN}"
################################################################################
. /opt/harbor/keystone/manage/env-keystone-admin-auth.sh
IPA_REALM_DESCRIPTION="${OS_DOMAIN} user domain"
(openstack domain create --description "${IPA_REALM_DESCRIPTION}" --enable ${OS_DOMAIN} && \
keystone-manage --debug --verbose domain_config_upload --domain-name ${OS_DOMAIN}) || \
openstack domain show ${OS_DOMAIN}



################################################################################
echo "${OS_DISTRO}: ${OPENSTACK_COMPONENT}: ${OPENSTACK_SUBCOMPONENT}: Getting the $IPA_USER_ADMIN_USER@$IPA_REALM user ID"
################################################################################
IPA_ADMIN_USER_ID=$( openstack user show --domain ${OS_DOMAIN} keystone \
                                        -f value -c id  )
