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
                    KEYSTONE_IPA_REALM \
                    IPSILON_SERVICE_HOST


echo "${OS_DISTRO}: Setting up ipsilon as an id provider"
################################################################################
openstack identity provider show ipsilon || \
    openstack identity provider create --description "${OS_DOMAIN}: Port Authority (SAML2)"\
    --enable ipsilon --remote-id https://${IPSILON_SERVICE_HOST}/idp/saml2/metadata


echo "${OS_DISTRO}: Managing idenity mapping"
################################################################################
cat > /tmp/ipsilon_mapping.json << EOF
[
  {
      "local": [
          {
              "user": {
                  "name": "{0}",
                  "type": "local",
                  "domain": {
                                "name": "${OS_DOMAIN}"
                            }
              },
              "groups": "{1}",
              "domain": {
                            "name": "${OS_DOMAIN}"
                        }
          }
      ],
      "remote": [
          {
              "type": "MELLON_NAME_ID"
          },
          {
              "type": "MELLON_groups"
          }
      ]
  }
]
EOF
openstack mapping show ipsilon_mapping || openstack mapping create --rules /tmp/ipsilon_mapping.json ipsilon_mapping


echo "${OS_DISTRO}: managing federated protocol"
################################################################################
openstack federation protocol show --identity-provider ipsilon saml2 || \
    openstack federation protocol create --identity-provider ipsilon --mapping ipsilon_mapping saml2


echo "${OS_DISTRO}: admins group"
################################################################################
OS_GROUP=admins
KEYSTONE_PROJECT=${OS_GROUP}
OS_GROUP_DESC=$(openstack group show --domain ${OS_DOMAIN} ${OS_GROUP} -f value -c description)
openstack project create --description "${OS_GROUP_DESC}" --or-show --domain ${OS_DOMAIN} ${KEYSTONE_PROJECT}
openstack role add --project-domain ${OS_DOMAIN} --project ${KEYSTONE_PROJECT} --group-domain ${OS_DOMAIN} --group ${OS_GROUP} "admin"
openstack role add --project-domain ${OS_DOMAIN} --project ${KEYSTONE_PROJECT} --group-domain ${OS_DOMAIN} --group ${OS_GROUP} "Member"


echo "${OS_DISTRO}: managing ipausers group"
################################################################################
OS_GROUP=ipausers
KEYSTONE_PROJECT=${OS_GROUP}
OS_GROUP_DESC=$(openstack group show --domain ${OS_DOMAIN} ${OS_GROUP} -f value -c description)
openstack project create --description "${OS_GROUP_DESC}" --or-show --domain ${OS_DOMAIN} ${KEYSTONE_PROJECT}
openstack role add --project-domain ${OS_DOMAIN} --project ${KEYSTONE_PROJECT} --group-domain ${OS_DOMAIN} --group ${OS_GROUP} "Member"
