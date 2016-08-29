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
echo "${OS_DISTRO}: Installing Ipsilon"
################################################################################
. /etc/os-container.env
. /opt/harbor/service-hosts.sh
. /opt/harbor/harbor-common.sh
. /opt/harbor/ipsilon/vars.sh


################################################################################
check_required_vars OS_DOMAIN \
                    IPSILON_DATA_DIR \
                    FREEIPA_SERVICE_HOST \
                    IPSILON_SERVICE_HOST \
                    IPSILON_HOSTNAME \
                    IPSILON_SERVICE_NAMESPACE \
                    IPSILON_DB_SERVICE_HOST_SVC \
                    IPSILON_DB_SERVICE_PORT \
                    IPSILON_DB_CA \
                    IPSILON_DB_KEY \
                    IPSILON_DB_CERT \
                    IPSILON_DATABASES \
                    IPSILON_API_TLS_CA \
                    AUTH_FREEIPA_USER_ADMIN_USER \
                    AUTH_FREEIPA_USER_ADMIN_PASSWORD \
                    AUTH_IPSILON_ADMIN_DB_USER \
                    AUTH_IPSILON_ADMIN_DB_PASSWORD \
                    AUTH_IPSILON_ADMIN_DB_NAME \
                    AUTH_IPSILON_USERS_DB_USER \
                    AUTH_IPSILON_USERS_DB_PASSWORD \
                    AUTH_IPSILON_USERS_DB_NAME \
                    AUTH_IPSILON_TRANS_DB_USER \
                    AUTH_IPSILON_TRANS_DB_PASSWORD \
                    AUTH_IPSILON_TRANS_DB_NAME \
                    AUTH_IPSILON_SAMLSESSION_DB_USER \
                    AUTH_IPSILON_SAMLSESSION_DB_PASSWORD \
                    AUTH_IPSILON_SAMLSESSION_DB_NAME \
                    AUTH_IPSILON_SAML2SESSION_DB_USER \
                    AUTH_IPSILON_SAML2SESSION_DB_PASSWORD \
                    AUTH_IPSILON_SAML2SESSION_DB_NAME \
                    AUTH_IPSILON_OPENID_DB_USER \
                    AUTH_IPSILON_OPENID_DB_PASSWORD \
                    AUTH_IPSILON_OPENID_DB_NAME \
                    AUTH_IPSILON_OPENIDC_DB_USER \
                    AUTH_IPSILON_OPENIDC_DB_PASSWORD \
                    AUTH_IPSILON_OPENIDC_DB_NAME


################################################################################
cat ${IPSILON_DB_CA} >> /etc/ssl/certs/ca-bundle.crt
cat ${IPSILON_API_TLS_CA} >> /etc/ssl/certs/ca-bundle.crt


################################################################################
rm -rf /etc/ipsilon
mkdir -p ${IPSILON_DATA_DIR}/etc/ipsilon
ln -s ${IPSILON_DATA_DIR}/ipsilon /etc/ipsilon


################################################################################
rm -rf /var/lib/ipsilon
mkdir -p ${IPSILON_DATA_DIR}/var/lib/ipsilon
ln -s ${IPSILON_DATA_DIR}/var/lib/ipsilon /var/lib/ipsilon


################################################################################
ipsilon-server-install \
--server-debugging \
--hostname="${IPSILON_SERVICE_HOST}" \
--testauth=no \
--secure=yes \
--ldap=yes \
--ldap-server-url="ldap://${FREEIPA_SERVICE_HOST}" \
--ldap-bind-dn-template="uid=%(username)s,cn=users,cn=accounts,dc=${OS_DOMAIN}" \
--ldap-tls-level="Never" \
--ldap-base-dn "dc=${OS_DOMAIN}" \
--info-nss=no \
--info-ldap=yes \
--info-ldap-server-url="ldap://${FREEIPA_SERVICE_HOST}" \
--info-ldap-user-dn-template="uid=%(username)s,cn=users,cn=accounts,dc=${OS_DOMAIN}" \
--info-ldap-bind-dn="uid=${AUTH_FREEIPA_USER_ADMIN_USER},cn=users,cn=accounts,dc=${OS_DOMAIN}" \
--info-ldap-bind-pwd="${AUTH_FREEIPA_USER_ADMIN_PASSWORD}" \
--info-ldap-base-dn="cn=accounts,dc=${OS_DOMAIN}"\
--admin-dburi="postgres://${AUTH_IPSILON_ADMIN_DB_USER}:${AUTH_IPSILON_ADMIN_DB_PASSWORD}@${IPSILON_DB_SERVICE_HOST_SVC}/${AUTH_IPSILON_ADMIN_DB_NAME}" \
--users-dburi="postgres://${AUTH_IPSILON_USERS_DB_USER}:${AUTH_IPSILON_USERS_DB_PASSWORD}@${IPSILON_DB_SERVICE_HOST_SVC}/${AUTH_IPSILON_USERS_DB_NAME}" \
--transaction-dburi="postgres://${AUTH_IPSILON_TRANS_DB_USER}:${AUTH_IPSILON_TRANS_DB_PASSWORD}@${IPSILON_DB_SERVICE_HOST_SVC}/${AUTH_IPSILON_TRANS_DB_NAME}" \
--samlsessions-dburi="postgres://${AUTH_IPSILON_SAMLSESSION_DB_USER}:${AUTH_IPSILON_SAMLSESSION_DB_PASSWORD}@${IPSILON_DB_SERVICE_HOST_SVC}/${AUTH_IPSILON_SAMLSESSION_DB_NAME}" \
--saml2-session-dburl="postgres://${AUTH_IPSILON_SAML2SESSION_DB_USER}:${AUTH_IPSILON_SAML2SESSION_DB_PASSWORD}@${IPSILON_DB_SERVICE_HOST_SVC}/${AUTH_IPSILON_SAML2SESSION_DB_NAME}" \
--openid-dburi="postgres://${AUTH_IPSILON_OPENID_DB_USER}:${AUTH_IPSILON_OPENID_DB_PASSWORD}@${IPSILON_DB_SERVICE_HOST_SVC}/${AUTH_IPSILON_OPENID_DB_NAME}" \
--openidc-dburi="postgres://${AUTH_IPSILON_OPENIDC_DB_USER}:${AUTH_IPSILON_OPENIDC_DB_PASSWORD}@${IPSILON_DB_SERVICE_HOST_SVC}/${AUTH_IPSILON_OPENIDC_DB_NAME}"
