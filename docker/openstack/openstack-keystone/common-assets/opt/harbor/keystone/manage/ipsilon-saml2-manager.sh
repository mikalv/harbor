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
echo "${OS_DISTRO}: Managing tokens"
################################################################################
. /etc/os-container.env
. /opt/harbor/service-hosts.sh
. /opt/harbor/harbor-common.sh
. /opt/harbor/keystone/vars.sh


################################################################################
check_required_vars KEYSTONE_CONFIG_FILE \
                    IPSILON_SERVICE_HOST_SVC \
                    AUTH_FREEIPA_USER_ADMIN_USER \
                    AUTH_FREEIPA_USER_ADMIN_PASSWORD \
                    KEYSTONE_API_TLS_CA \
                    KEYSTONE_API_SERVICE_HOST \
                    KEYSTONE_API_SERVICE_HOST_SVC

################################################################################
LOCAL_AUTH_DIR="$HOME/.harbor"
mkdir -p ${LOCAL_AUTH_DIR}

echo -n "${AUTH_FREEIPA_USER_ADMIN_USER}" > ${LOCAL_AUTH_DIR}/idp_username.txt
echo -n "${AUTH_FREEIPA_HOST_ADMIN_PASSWORD}" > ${LOCAL_AUTH_DIR}/idp_password.txt
curl --cacert ${KEYSTONE_API_TLS_CA} \
     --data-urlencode login_name@${LOCAL_AUTH_DIR}/idp_username.txt \
     --data-urlencode login_password@${LOCAL_AUTH_DIR}/idp_password.txt \
     -b ${LOCAL_AUTH_DIR}/cookies -c ${LOCAL_AUTH_DIR}/cookies \
     https://${IPSILON_SERVICE_HOST_SVC}/idp/login/ldap
rm -f ${LOCAL_AUTH_DIR}/idp_password.txt
rm -f ${LOCAL_AUTH_DIR}/idp_username.txt


generate_service_cirt () {
  echo "${OS_DISTRO}: generating certs for keystone <-> ipsilon (saml2)"
  ################################################################################

  curl --cacert ${KEYSTONE_API_TLS_CA} \
      -b /etc/httpd/mellon/cookies \
      -c /etc/httpd/mellon/cookies \
      --fail \
      https://${IPSILON_SERVICE_HOST_SVC}/idp/admin/providers/saml2/admin/sp/keystone/delete

curl --cacert ${KEYSTONE_API_TLS_CA} \
    -b /etc/httpd/mellon/cookies \
    -c /etc/httpd/mellon/cookies \
    --fail \
    https://${IPSILON_SERVICE_HOST_SVC}/idp/admin/providers/saml2/admin/sp/${KEYSTONE_API_SERVICE_HOST}/delete || true

curl --cacert ${KEYSTONE_API_TLS_CA} \
     -b /etc/httpd/mellon/cookies \
     -c /etc/httpd/mellon/cookies \
     --fail \
     https://${IPSILON_SERVICE_HOST_SVC}/idp/admin/providers/saml2/admin/sp/${IPSION_SP_NAME} || ( \

cd /etc/httpd/mellon
ipsilon-client-install --uninstall || true
cat ${KEYSTONE_API_TLS_CA} >> /etc/ssl/certs/ca-bundle.crt
echo ${AUTH_FREEIPA_USER_ADMIN_PASSWORD} | ipsilon-client-install --debug \
--hostname ${KEYSTONE_API_SERVICE_HOST} \
--admin-user ${AUTH_FREEIPA_USER_ADMIN_USER} \
--admin-password - \
--saml-no-httpd \
--saml-idp-url https://${IPSILON_SERVICE_HOST_SVC}/idp \
--saml-auth "/federation" \
--saml-sp "/v3/OS-FEDERATION/identity_providers/ipsilon/protocols/saml2/auth/mellon" \
--saml-sp-logout "/v3/OS-FEDERATION/identity_providers/ipsilon/protocols/saml2/auth/mellon/logout" \
--saml-sp-post "/v3/OS-FEDERATION/identity_providers/ipsilon/protocols/saml2/auth/mellon/postResponse" \
--saml-sp-paos "/v3/OS-FEDERATION/identity_providers/ipsilon/protocols/saml2/auth/mellon/paosResponse" \
--saml-sp-name "${KEYSTONE_API_SERVICE_HOST}" \
--saml-sp-description "${OS_DOMAIN}: ${KEYSTONE_API_SERVICE_HOST}" \
--debug
mkdir -p /run/harbor/auth/mellon
cat /etc/httpd/mellon/certificate.pem > ${KEYSTONE_MELLON_SP_TLS_CERT}
cat /etc/httpd/mellon/certificate.key > ${KEYSTONE_MELLON_SP_TLS_KEY}
cat /etc/httpd/mellon/metadata.xml > ${KEYSTONE_MELLON_SP_METADATA}
curl -L https://${IPSILON_SERVICE_HOST_SVC}/idp/saml2/metadata > ${KEYSTONE_MELLON_IDP_METADATA}


cat > ${LOCAL_AUTH_DIR}/keystone-federation-saml2-secret.yaml <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: keystone-federation-saml2-secret
  namespace: os-keystone
type: Opaque
data:
  sp-metadata.xml: $( cat ${KEYSTONE_MELLON_SP_METADATA} | base64 --wrap=0 )
  tls.crt: $( cat ${KEYSTONE_MELLON_SP_TLS_CERT} | base64 --wrap=0 )
  tls.key: $( cat ${KEYSTONE_MELLON_SP_TLS_CERT} | base64 --wrap=0 )
  idp-metadata.xml: $( cat ${KEYSTONE_MELLON_IDP_METADATA} | base64 --wrap=0 )
EOF
