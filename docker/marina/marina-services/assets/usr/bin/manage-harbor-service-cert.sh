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

source /etc/os-container.env
export OS_DOMAIN=$(hostname -d)
source /etc/os-container.env
source /opt/harbor/harbor-common.sh
source /opt/harbor/service-hosts.sh
source /opt/harbor/freeipa-login-helper.sh
source /opt/harbor/marina/load-config-helper.sh


freeipa_update_dns () {
  SERVICE_HOSTNAME=$1
  SERVICE_IP=$2

  check_required_vars SERVICE_HOSTNAME \
                      SERVICE_IP

  (ipa dnsrecord-show ${OS_DOMAIN} ${SERVICE_HOSTNAME} --raw && (
  IPA_SVC_IP=$(ipa dnsrecord-show ${OS_DOMAIN} ${SERVICE_HOSTNAME} --raw | grep "arecord" | awk '{printf $NF}' | head -1)
  if [ "${IPA_SVC_IP}" != "${SERVICE_IP}" ]; then
    ipa dnsrecord-del ${OS_DOMAIN} ${SERVICE_HOSTNAME} --del-all
    ipa dnsrecord-add ${OS_DOMAIN} ${SERVICE_HOSTNAME} --a-rec=${SERVICE_IP}
  fi
  )) || ipa dnsrecord-add ${OS_DOMAIN} ${SERVICE_HOSTNAME} --a-rec=${SERVICE_IP}
}

freeipa_update_host () {
  SERVICE_HOSTNAME=$1

  check_required_vars SERVICE_HOSTNAME \
                      OS_SERVICE_LOCALITY \
                      OS_SERVICE_LOCATION \
                      OS_SERVICE_PLATFORM \
                      OS_SERVICE_DESC

  ipa host-show ${SERVICE_HOSTNAME}.${OS_DOMAIN} || \
   /bin/sh -c "ipa host-add ${SERVICE_HOSTNAME}.${OS_DOMAIN} --class=kubernetes_service \
   --locality=${OS_SERVICE_LOCALITY} \
   --location=${OS_SERVICE_LOCATION} \
   --platform=${OS_SERVICE_PLATFORM} \
   --desc='${OS_SERVICE_DESC}'"

  ipa host-add-managedby ${SERVICE_HOSTNAME}.${OS_DOMAIN} --hosts=$(hostname --fqdn) || true
}


freeipa_update_service () {
  SERVICE_TYPE=$1
  SERVICE_HOSTNAME=$2

  check_required_vars OS_SERVICE_TYPE \
                      OS_SERVICE

  ipa service-show ${OS_SERVICE_TYPE}/${OS_SERVICE}.${OS_DOMAIN} || \
  ipa service-add ${OS_SERVICE_TYPE}/${OS_SERVICE}.${OS_DOMAIN}  && \

  ipa service-add-host ${OS_SERVICE_TYPE}/${OS_SERVICE}.${OS_DOMAIN} --hosts=$(hostname --fqdn) || true
}



freeipa_add_file_to_service_vault () {
  SERVICE=$1
  SERVICE_TYPE=$2
  VAULT_PASSWORD_FILE=$3
  FILE=$4

  check_required_vars SERVICE \
                      SERVICE_TYPE \
                      VAULT_PASSWORD_FILE \
                      FILE

  VAULT_NAME=$(basename $FILE)

  ipa vault-show --service ${SERVICE_TYPE}/${SERVICE}.${OS_DOMAIN} ${VAULT_NAME} || \
  ipa vault-add ${VAULT_NAME} --service ${SERVICE_TYPE}/${SERVICE}.${OS_DOMAIN} --type symmetric --password-file ${VAULT_PASSWORD_FILE}

  ipa vault-archive ${VAULT_NAME} \
  --service ${SERVICE_TYPE}/${SERVICE}.${OS_DOMAIN} \
  --password-file ${VAULT_PASSWORD_FILE} \
  --in ${FILE}
}

freeipa_get_file_from_service_vault () {
  SERVICE=$1
  SERVICE_TYPE=$2
  VAULT_PASSWORD_FILE=$3
  VAULT_NAME=$4
  FILE=$5

  check_required_vars SERVICE \
                      SERVICE_TYPE \
                      VAULT_PASSWORD_FILE \
                      FILE \
                      VAULT_NAME

  ipa vault-retrieve ${VAULT_NAME} \
  --service ${SERVICE_TYPE}/${SERVICE}.${OS_DOMAIN} \
  --password-file ${VAULT_PASSWORD_FILE} \
  --out $FILE
}


freeipa_check_file_in_service_vault () {
  SERVICE=$1
  SERVICE_TYPE=$2
  VAULT_PASSWORD_FILE=$3
  VAULT_NAME=$4

  check_required_vars SERVICE \
                      SERVICE_TYPE \
                      VAULT_PASSWORD_FILE \
                      VAULT_NAME

  ipa vault-show ${VAULT_NAME} \
  --service ${SERVICE_TYPE}/${SERVICE}.${OS_DOMAIN}
}

freeipa_request_service_certs () {
  SERVICE=$1
  SVC_TYPE=$2
  KUBE_NAMESPACE=$3
  VAULT_PASSWORD_FILE=$4
  CERT_BASE=$5

  check_required_vars SERVICE \
                      SVC_TYPE \
                      CERT_BASE \
                      KUBE_NAMESPACE \
                      OS_SERVICE_PLATFORM \
                      VAULT_PASSWORD_FILE \
                      CERT_BASE

  mkdir -p ${CERT_BASE}
  CERT_FILE_ROOT="${CERT_BASE}/${SVC_TYPE}-${SERVICE}"

  ipa-getcert request -w -r \
      -f ${CERT_FILE_ROOT}.crt \
      -k ${CERT_FILE_ROOT}.key \
      -F ${CERT_FILE_ROOT}-ca.crt \
      -N "CN=${SERVICE}.${OS_DOMAIN}" \
      -D "${SERVICE}.${OS_DOMAIN}" \
      -D "${SERVICE}.${KUBE_NAMESPACE}" \
      -D "${SERVICE}.${KUBE_NAMESPACE}.svc" \
      -D "${SERVICE}.${KUBE_NAMESPACE}.svc.${OS_DOMAIN}" \
      -D "*.${KUBE_NAMESPACE}.pod" \
      -D "*.${KUBE_NAMESPACE}.pod.${OS_DOMAIN}" \
      -D "${SERVICE}.${OS_DOMAIN}" \
      -K "${SVC_TYPE}/${SERVICE}.${OS_DOMAIN}"

  wait_for_file 60 2 ${CERT_FILE_ROOT}.crt

  openssl verify -CAfile ${CERT_FILE_ROOT}-ca.crt ${CERT_FILE_ROOT}.crt
  openssl x509 -in ${CERT_FILE_ROOT}.crt -noout -text

  freeipa_add_file_to_service_vault $SERVICE $SVC_TYPE $VAULT_PASSWORD_FILE ${CERT_FILE_ROOT}-ca.crt
  freeipa_add_file_to_service_vault $SERVICE $SVC_TYPE $VAULT_PASSWORD_FILE ${CERT_FILE_ROOT}.crt
  freeipa_add_file_to_service_vault $SERVICE $SVC_TYPE $VAULT_PASSWORD_FILE ${CERT_FILE_ROOT}.key

  rm -f ${CERT_FILE_ROOT}-ca.crt
  rm -f ${CERT_FILE_ROOT}.crt
  rm -f ${CERT_FILE_ROOT}.key
}

freeipa_retreve_service_certs () {
  SERVICE=$1
  SVC_TYPE=$2
  KUBE_NAMESPACE=$3
  VAULT_PASSWORD_FILE=$4
  CERT_BASE=$5

  check_required_vars SERVICE \
                      SVC_TYPE \
                      CERT_BASE \
                      KUBE_NAMESPACE \
                      VAULT_PASSWORD_FILE \
                      CERT_BASE

  mkdir -p ${CERT_BASE}
  CERT_FILE_BASE="${SVC_TYPE}-${SERVICE}"
  CERT_FILE_ROOT="${CERT_BASE}/${CERT_FILE_BASE}"

  freeipa_get_file_from_service_vault $SERVICE $SVC_TYPE $VAULT_PASSWORD_FILE ${CERT_FILE_BASE}-ca.crt ${CERT_FILE_ROOT}-ca.crt
  freeipa_get_file_from_service_vault $SERVICE $SVC_TYPE $VAULT_PASSWORD_FILE ${CERT_FILE_BASE}.crt ${CERT_FILE_ROOT}.crt
  freeipa_get_file_from_service_vault $SERVICE $SVC_TYPE $VAULT_PASSWORD_FILE ${CERT_FILE_BASE}.key ${CERT_FILE_ROOT}.key
  echo $CERT_FILE_ROOT
  openssl verify -CAfile ${CERT_FILE_ROOT}-ca.crt ${CERT_FILE_ROOT}.crt
  openssl x509 -in ${CERT_FILE_ROOT}.crt -noout -text
}

freeipa_check_service_certs_in_vault () {
  SERVICE=$1
  SVC_TYPE=$2
  KUBE_NAMESPACE=$3
  VAULT_PASSWORD_FILE=$4

  check_required_vars SERVICE \
                      SVC_TYPE \
                      KUBE_NAMESPACE \
                      VAULT_PASSWORD_FILE

  CERT_FILE_BASE="${SVC_TYPE}-${SERVICE}"

  freeipa_check_file_in_service_vault $SERVICE $SVC_TYPE $VAULT_PASSWORD_FILE ${CERT_FILE_BASE}-ca.crt && \
  freeipa_check_file_in_service_vault $SERVICE $SVC_TYPE $VAULT_PASSWORD_FILE ${CERT_FILE_BASE}.crt && \
  freeipa_check_file_in_service_vault $SERVICE $SVC_TYPE $VAULT_PASSWORD_FILE ${CERT_FILE_BASE}.key
}

freeipa_get_service_certs () {
  SERVICE=$1
  SVC_TYPE=$2
  KUBE_NAMESPACE=$3
  VAULT_PASSWORD_FILE=$4
  CERT_FILE_ROOT=$5

  check_required_vars SERVICE \
                      SVC_TYPE \
                      KUBE_NAMESPACE \
                      VAULT_PASSWORD_FILE \
                      CERT_FILE_ROOT

  freeipa_check_service_certs_in_vault $SERVICE $SVC_TYPE $KUBE_NAMESPACE $VAULT_PASSWORD_FILE || \
  freeipa_request_service_certs $SERVICE $SVC_TYPE $KUBE_NAMESPACE $VAULT_PASSWORD_FILE $CERT_FILE_ROOT

  freeipa_retreve_service_certs $SERVICE $SVC_TYPE $KUBE_NAMESPACE $VAULT_PASSWORD_FILE $CERT_FILE_ROOT
}

kube_load_service_certs () {
  SERVICE=$1
  SVC_TYPE=$2
  CERT_BASE=$3
  KUBE_BASE=$4

  check_required_vars SERVICE \
                      SVC_TYPE \
                      CERT_BASE \
                      CERT_BASE

  CERT_FILE_ROOT="${CERT_BASE}/${SVC_TYPE}-${SERVICE}"

  openssl verify -CAfile ${CERT_FILE_ROOT}-ca.crt ${CERT_FILE_ROOT}.crt
  openssl x509 -in ${CERT_FILE_ROOT}.crt -noout -text

  cat ${CERT_FILE_ROOT}-ca.crt > $KUBE_BASE/ca.crt
  cat ${CERT_FILE_ROOT}.crt > $KUBE_BASE/server.cert
  cat ${CERT_FILE_ROOT}.key > $KUBE_BASE/server.key

  openssl verify -CAfile $KUBE_BASE/ca.crt $KUBE_BASE/server.cert
  openssl x509 -in $KUBE_BASE/server.cert -noout -text
}

container_clean_service_certs () {
  SERVICE=$1
  SVC_TYPE=$2
  CERT_BASE=$3

  check_required_vars SERVICE \
                      SVC_TYPE \
                      CERT_BASE \
                      CERT_BASE

  CERT_FILE_ROOT="${CERT_BASE}/${SVC_TYPE}-${SERVICE}"

  rm -rf ${CERT_BASE}/${SVC_TYPE}-${SERVICE}
  mkdir -p ${CERT_BASE}/${SVC_TYPE}-${SERVICE}
}

kube_upload_service_certs () {
  SERVICE=$1
  SVC_TYPE=$2
  CERT_BASE=$3
  KUBE_BASE=$4
  KUBE_NAMESPACE=$5

  check_required_vars SERVICE \
                      SVC_TYPE \
                      CERT_BASE \
                      KUBE_BASE \
                      KUBE_NAMESPACE

  CERT_FILE_ROOT="${CERT_BASE}/${SVC_TYPE}-${SERVICE}"


  check_required_vars HARBOR_SERVICE_DEFAULT_IP \
                      OS_DOMAIN
  echo "$HARBOR_SERVICE_DEFAULT_IP kubernetes.${OS_DOMAIN} kubernetes.default kubernetes.default.svc kubernetes.default.svc.${OS_DOMAIN}" >> /etc/hosts

  KUBE_ADMIN_USER=admin
  KUBE_ADMIN_TOKEN=$(cat ${KUBE_BASE}/known_tokens.csv | grep ",$KUBE_ADMIN_USER$" | awk -F ',' '{ print $1 }')
  cat > ${CERT_FILE_ROOT}-ssl-secret.yaml <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: ${SERVICE}-ssl-secret
  namespace: ${MARINA_SERVICE_NAMESPACE}
type: Opaque
data:
  host: $( echo "${SERVICE}.${OS_DOMAIN}" | base64 --wrap=0 )
  ca: $( cat ${CERT_FILE_ROOT}-ca.crt | base64 --wrap=0 )
  crt: $( cat ${CERT_FILE_ROOT}.crt | base64 --wrap=0 )
  key: $( cat ${CERT_FILE_ROOT}.key | base64 --wrap=0 )
EOF

  kubectl --server https://kubernetes.${OS_DOMAIN}:6443 --user=${KUBE_ADMIN_USER} --token=${KUBE_ADMIN_TOKEN} delete -f ${CERT_FILE_ROOT}-ssl-secret.yaml || true
  kubectl --server https://kubernetes.${OS_DOMAIN}:6443 --user=${KUBE_ADMIN_USER} --token=${KUBE_ADMIN_TOKEN} create -f ${CERT_FILE_ROOT}-ssl-secret.yaml
}

freeipa_update_service_certs () {
  freeipa_login
  freeipa_update_dns $OS_SERVICE $OS_SERVICE_IP
  freeipa_update_host $OS_SERVICE
  freeipa_update_service $OS_SERVICE_TYPE $OS_SERVICE

  export CERT_OUTPUT_ROOT="/etc/harbor/marina/${MARINA_SERVICE}/${OS_SERVICE_TYPE}"
  if [ "$MARINA_SERVICE" = "kubernetes" ]; then
    echo "Service is Kubernetes"
    MARINA_SERVICE_NAMESPACE="default"
  else
    echo "$MARINA_SERVICE"
    MARINA_SERVICE_NAMESPACE="os-${MARINA_SERVICE}"
  fi;

  MARINA_SERVICE_VAULT_PASSWORD_FILE=/tmp/$(uuidgen)
  (crudini --get /etc/harbor/harbor-auth.conf $MARINA_SERVICE harbor_auth_vault_cert_password || \
  crudini --set /etc/harbor/harbor-auth.conf $MARINA_SERVICE harbor_auth_vault_cert_password $(harbor-gen-password 64 96)) >> /dev/null
  crudini --get /etc/harbor/harbor-auth.conf $MARINA_SERVICE harbor_auth_vault_cert_password > $MARINA_SERVICE_VAULT_PASSWORD_FILE

  freeipa_get_service_certs $OS_SERVICE $OS_SERVICE_TYPE $MARINA_SERVICE_NAMESPACE $MARINA_SERVICE_VAULT_PASSWORD_FILE $CERT_OUTPUT_ROOT
  rm -f $MARINA_SERVICE_VAULT_PASSWORD_FILE
  freeipa_logout
  if [ "$MARINA_SERVICE" = "kubernetes" ]; then
    echo "Service is Kubernetes"
    kube_load_service_certs $OS_SERVICE $OS_SERVICE_TYPE $CERT_OUTPUT_ROOT /var/lib/harbor/kube
  else
    echo "$MARINA_SERVICE"
    kube_upload_service_certs $OS_SERVICE $OS_SERVICE_TYPE $CERT_OUTPUT_ROOT /var/lib/harbor/kube $MARINA_SERVICE_NAMESPACE
  fi;
  container_clean_service_certs $OS_SERVICE $OS_SERVICE_TYPE $CERT_OUTPUT_ROOT
}





freeipa_update_service_user_certs () {
  IPA_USER=${MARINA_SERVICE}
  IPA_USER_EMAIL="${IPA_USER}@${OS_DOMAIN}.local"
  IPA_USER_GROUP="keystone_pki_users"
  IPA_CERT_PROFILE=caIPAclientCert


  MARINA_SERVICE_VAULT_PASSWORD_FILE=/tmp/$(uuidgen)
  (crudini --get /etc/harbor/harbor-auth.conf $MARINA_SERVICE harbor_auth_vault_user_cert_password || \
  crudini --set /etc/harbor/harbor-auth.conf $MARINA_SERVICE harbor_auth_vault_user_cert_password $(harbor-gen-password 64 96)) >> /dev/null
  crudini --get /etc/harbor/harbor-auth.conf $MARINA_SERVICE harbor_auth_vault_user_cert_password > $MARINA_SERVICE_VAULT_PASSWORD_FILE
  (crudini --get /etc/harbor/harbor-auth.conf $MARINA_SERVICE harbor_auth_vault_user_cert_user || \
  crudini --set /etc/harbor/harbor-auth.conf $MARINA_SERVICE harbor_auth_vault_user_cert_user ${IPA_USER}) >> /dev/null
  IPA_VAULT_USER=$(crudini --get /etc/harbor/harbor-auth.conf $MARINA_SERVICE harbor_auth_vault_user_cert_user)


  freeipa_login


  ipa group-show ${IPA_USER_GROUP} || ipa group-add  ${IPA_USER_GROUP}
  ipa caacl-show ${IPA_USER_GROUP}_acl || ipa caacl-add ${IPA_USER_GROUP}_acl
  ipa caacl-add-user ${IPA_USER_GROUP}_acl --group ${IPA_USER_GROUP} || true
  ipa caacl-add-profile ${IPA_USER_GROUP}_acl --certprofile ${IPA_CERT_PROFILE} || true
  ipa caacl-add-profile ${IPA_USER_GROUP}_acl --certprofile ${IPA_CERT_PROFILE} || true


  ipa user-show ${IPA_USER} || ipa user-add ${IPA_USER} --first=${IPA_USER^} --last=OpenStack --email ${IPA_USER}@${OS_DOMAIN}.local
  ipa group-add-member ${IPA_USER_GROUP} --users=${IPA_USER} || true


  (
  rm -rf /tmp/user
  mkdir -p /tmp/user
  for VAULT_NAME in ${IPA_USER}-ca.crt ${IPA_USER}.crt ${IPA_USER}.key
  do
      ipa vault-retrieve --user ${IPA_VAULT_USER} ${VAULT_NAME} \
      --password-file ${MARINA_SERVICE_VAULT_PASSWORD_FILE} \
      --out /tmp/user/${VAULT_NAME} || (
      for VAULT_NAME in ${IPA_USER}-ca.crt ${IPA_USER}.crt ${IPA_USER}.key
      do
          ipa vault-del --user ${IPA_VAULT_USER} ${VAULT_NAME} || true
      done
      )
  done
  openssl x509 -in /tmp/user/${IPA_USER}.crt -noout -text && \
  cat /etc/ipa/ca.crt > /tmp/user/${IPA_USER}-ca.crt && \
  openssl verify -CAfile /tmp/user/${IPA_USER}-ca.crt /tmp/user/${IPA_USER}.crt
  ) || (

  rm -rf /tmp/user
  mkdir -p /tmp/user

  openssl genrsa -out /tmp/user/${IPA_USER}.key 2048

cat > /tmp/user/${IPA_USER}.conf <<EOF
[ req ]
prompt = no
encrypt_key = no

distinguished_name = dn
req_extensions = exts

[ dn ]
commonName = "${IPA_USER}"

[ exts ]
subjectAltName=email:${IPA_USER_EMAIL}
EOF

  openssl req -new -key /tmp/user/${IPA_USER}.key -out /tmp/user/${IPA_USER}.csr -config /tmp/user/${IPA_USER}.conf

  openssl req -text -in /tmp/user/${IPA_USER}.csr

  IPA_USER_CERT_SN=$(ipa cert-request /tmp/user/${IPA_USER}.csr --principal ${IPA_USER} --profile-id ${IPA_CERT_PROFILE} | grep "^  Serial number:" | awk '{ print $NF }')
  ipa cert-show ${IPA_USER_CERT_SN} --out /tmp/user/${IPA_USER}.crt

  openssl x509 -in /tmp/user/${IPA_USER}.crt -noout -text

  cat /etc/ipa/ca.crt > /tmp/user/${IPA_USER}-ca.crt
  openssl verify -CAfile /tmp/user/${IPA_USER}-ca.crt /tmp/user/${IPA_USER}.crt

  for VAULT_NAME in ${IPA_USER}-ca.crt ${IPA_USER}.crt ${IPA_USER}.key
  do
      ipa vault-del --user ${IPA_VAULT_USER} ${VAULT_NAME} || true
  done

  for VAULT_NAME in ${IPA_USER}-ca.crt ${IPA_USER}.crt ${IPA_USER}.key
  do
      ipa vault-show --user ${IPA_VAULT_USER} ${VAULT_NAME} || \
      ipa vault-add ${VAULT_NAME} --user ${IPA_VAULT_USER} --type symmetric --password-file ${MARINA_SERVICE_VAULT_PASSWORD_FILE}

      ipa vault-archive --user ${IPA_VAULT_USER} \
      ${VAULT_NAME} \
      --password-file ${MARINA_SERVICE_VAULT_PASSWORD_FILE} \
      --in /tmp/user/${VAULT_NAME}
  done
  )

  freeipa_logout


  KUBE_ADMIN_USER=admin
  KUBE_ADMIN_TOKEN=$(cat ${KUBE_BASE}/known_tokens.csv | grep ",$KUBE_ADMIN_USER$" | awk -F ',' '{ print $1 }')
  cat > /tmp/user/${IPA_USER}-user-ssl-secret.yaml <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: ${IPA_USER}-user-ssl-secret
  namespace: ${MARINA_SERVICE_NAMESPACE}
type: Opaque
data:
  user: $( echo "${IPA_USER}" | base64 --wrap=0 )
  ca: $( cat /tmp/user/${IPA_USER}-ca.crt | base64 --wrap=0 )
  crt: $( cat /tmp/user/${IPA_USER}.crt | base64 --wrap=0 )
  key: $( cat /tmp/user/${IPA_USER}.key | base64 --wrap=0 )
EOF

  kubectl --server https://kubernetes.${OS_DOMAIN}:6443 --user=${KUBE_ADMIN_USER} --token=${KUBE_ADMIN_TOKEN} delete -f /tmp/user/${IPA_USER}-user-ssl-secret.yaml || true
  kubectl --server https://kubernetes.${OS_DOMAIN}:6443 --user=${KUBE_ADMIN_USER} --token=${KUBE_ADMIN_TOKEN} create -f /tmp/user/${IPA_USER}-user-ssl-secret.yaml

  rm -fr /tmp/user

}


load_network_config

OS_SERVICE_LOCALITY="HarborOS"
OS_SERVICE_LOCATION="Region1"
OS_SERVICE_PLATFORM="Kubernetes"



export OS_SERVICE=${MARINA_SERVICE}
export OS_SERVICE_TYPE=HTTP
export OS_SERVICE_DESC="${OS_SERVICE_PLATFORM} ${OS_SERVICE_LOCALITY} ${OS_SERVICE^} service"
if [ "$MARINA_SERVICE" = "kubernetes" ]; then
  echo "Service is Kubernetes"
  OS_SERVICE_IP=${NETWORK_KUBE_SERVICE_IPS_SERVICE_IP_KUBE}
else
  echo "$MARINA_SERVICE"
  OS_SERVICE_IP=${HARBOR_SERVICE_DEFAULT_IP}
fi;

freeipa_update_service_certs


if [ "$MARINA_SERVICE" = "kubernetes" ]; then
  echo "Service is Kubernetes"
else
  export OS_SERVICE=${MARINA_SERVICE}-db
  export OS_SERVICE_TYPE=mysql
  export OS_SERVICE_DESC="${OS_SERVICE_PLATFORM} ${OS_SERVICE_LOCALITY} ${OS_SERVICE^} service"
  freeipa_update_service_certs

  freeipa_update_service_user_certs
fi;
