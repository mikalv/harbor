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
                    AUTH_FREEIPA_USER_ADMIN_USER \
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
                    AUTH_IPSILON_OPENIDC_DB_NAME \
                    IPSILON_LDAP_BASE_DN


################################################################################
cat ${IPSILON_DB_CA} >> /etc/ssl/certs/ca-bundle.crt
cat ${IPSILON_API_TLS_CA} >> /etc/ssl/certs/ca-bundle.crt


echo "${OS_DISTRO}: clearing /etc/ipsilon"
################################################################################
rm -rf /etc/ipsilon
mkdir -p /etc/ipsilon


echo "${OS_DISTRO}: clearing /var/lib/ipsilon"
################################################################################
rm -rf /var/lib/ipsilon
mkdir -p /var/lib/ipsilon


if [ ! -f ${IPSILON_DATA_DIR}/installed ]; then
  echo "${OS_DISTRO}: Linking ${IPSILON_DATA_DIR}/etc/ipsilon to /etc/ipsilon"
  ################################################################################
  rm -rf /etc/ipsilon
  mkdir -p ${IPSILON_DATA_DIR}/etc/ipsilon
  ln -s ${IPSILON_DATA_DIR}/etc/ipsilon /etc/ipsilon


  echo "${OS_DISTRO}: Linking ${IPSILON_DATA_DIR}/var/lib/ipsilon to /var/lib/ipsilon"
  ################################################################################
  rm -rf /var/lib/ipsilon
  mkdir -p ${IPSILON_DATA_DIR}/var/lib/ipsilon
  ln -s ${IPSILON_DATA_DIR}/var/lib/ipsilon /var/lib/ipsilon
fi


echo "${OS_DISTRO}: Running ipsilon-server-install"
################################################################################
ipsilon-server-install \
--hostname="${IPSILON_SERVICE_HOST}" \
--admin-user="${AUTH_FREEIPA_USER_ADMIN_USER}" \
--testauth=no \
--secure=yes \
--ldap=yes \
--ldap-server-url="ldap://${FREEIPA_SERVICE_HOST}" \
--ldap-bind-dn-template="uid=%(username)s,cn=users,cn=accounts,${IPSILON_LDAP_BASE_DN}" \
--ldap-tls-level="Never" \
--ldap-base-dn "${IPSILON_LDAP_BASE_DN}" \
--info-nss=no \
--info-ldap=yes \
--info-ldap-server-url="ldap://${FREEIPA_SERVICE_HOST}" \
--info-ldap-user-dn-template="uid=%(username)s,cn=users,cn=accounts,${IPSILON_LDAP_BASE_DN}" \
--info-ldap-bind-dn="uid=${AUTH_FREEIPA_USER_ADMIN_USER},cn=users,cn=accounts,${IPSILON_LDAP_BASE_DN}" \
--info-ldap-bind-pwd="${AUTH_FREEIPA_USER_ADMIN_PASSWORD}" \
--info-ldap-base-dn="cn=accounts,${IPSILON_LDAP_BASE_DN}"\
--admin-dburi="postgres://${AUTH_IPSILON_ADMIN_DB_USER}:${AUTH_IPSILON_ADMIN_DB_PASSWORD}@${IPSILON_DB_SERVICE_HOST_SVC}/${AUTH_IPSILON_ADMIN_DB_NAME}" \
--users-dburi="postgres://${AUTH_IPSILON_USERS_DB_USER}:${AUTH_IPSILON_USERS_DB_PASSWORD}@${IPSILON_DB_SERVICE_HOST_SVC}/${AUTH_IPSILON_USERS_DB_NAME}" \
--transaction-dburi="postgres://${AUTH_IPSILON_TRANS_DB_USER}:${AUTH_IPSILON_TRANS_DB_PASSWORD}@${IPSILON_DB_SERVICE_HOST_SVC}/${AUTH_IPSILON_TRANS_DB_NAME}" \
--samlsessions-dburi="postgres://${AUTH_IPSILON_SAMLSESSION_DB_USER}:${AUTH_IPSILON_SAMLSESSION_DB_PASSWORD}@${IPSILON_DB_SERVICE_HOST_SVC}/${AUTH_IPSILON_SAMLSESSION_DB_NAME}" \
--saml2-session-dburl="postgres://${AUTH_IPSILON_SAML2SESSION_DB_USER}:${AUTH_IPSILON_SAML2SESSION_DB_PASSWORD}@${IPSILON_DB_SERVICE_HOST_SVC}/${AUTH_IPSILON_SAML2SESSION_DB_NAME}" \
--openid-dburi="postgres://${AUTH_IPSILON_OPENID_DB_USER}:${AUTH_IPSILON_OPENID_DB_PASSWORD}@${IPSILON_DB_SERVICE_HOST_SVC}/${AUTH_IPSILON_OPENID_DB_NAME}" \
--openidc-dburi="postgres://${AUTH_IPSILON_OPENIDC_DB_USER}:${AUTH_IPSILON_OPENIDC_DB_PASSWORD}@${IPSILON_DB_SERVICE_HOST_SVC}/${AUTH_IPSILON_OPENIDC_DB_NAME}"


if [ -f ${IPSILON_DATA_DIR}/installed ]; then
  echo "${OS_DISTRO}: Linking ${IPSILON_DATA_DIR}/etc/ipsilon to /etc/ipsilon"
  ################################################################################
  rm -rf /etc/ipsilon
  mkdir -p ${IPSILON_DATA_DIR}/etc/ipsilon
  ln -s ${IPSILON_DATA_DIR}/etc/ipsilon /etc/ipsilon


  echo "${OS_DISTRO}: Linking ${IPSILON_DATA_DIR}/var/lib/ipsilon to /var/lib/ipsilon"
  ################################################################################
  rm -rf /var/lib/ipsilon
  mkdir -p ${IPSILON_DATA_DIR}/var/lib/ipsilon
  ln -s ${IPSILON_DATA_DIR}/var/lib/ipsilon /var/lib/ipsilon
else
  echo "${OS_DISTRO}: Marking Ipsilon as installed"
  ################################################################################
  touch ${IPSILON_DATA_DIR}/installed
fi
