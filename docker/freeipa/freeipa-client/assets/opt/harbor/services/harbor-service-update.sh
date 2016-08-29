set -x
export OS_DOMAIN=$(hostname -d)
source /etc/os-container.env
source /opt/harbor/service-hosts.sh
source /opt/harbor/harbor-common.sh

FREEIPA_LOGIN_METHOD=password



OS_SERVICE=keystone-test
OS_SERVICE_IP=10.10.0.91
OS_SERVICE_TYPE=HTTP


OS_SERVICE_PHONE="8912847"
OS_SERVICE_LOCALITY="HarborOS"
OS_SERVICE_LOCATION="Region1"
OS_SERVICE_PLATFORM="Kubernetes"
OS_SERVICE_DESC="${OS_SERVICE_PLATFORM} ${OS_SERVICE_LOCALITY} ${OS_SERVICE^} service"

OS_SERVICE_VAULT_PASSWORD_FILE=/tmp/vault-password
echo "password123" > $OS_SERVICE_VAULT_PASSWORD_FILE

freeipa_login () {
  check_required_vars FREEIPA_LOGIN_METHOD
  if [ "$FREEIPA_LOGIN_METHOD" == 'keytab' ]; then
    kinit -k -t /etc/krb5.keytab
  elif [ "$FREEIPA_LOGIN_METHOD" == 'password' ]; then
    check_required_vars AUTH_FREEIPA_HOST_ADMIN_PASSWORD AUTH_FREEIPA_HOST_ADMIN_USER
    echo ${AUTH_FREEIPA_HOST_ADMIN_PASSWORD} | kinit ${AUTH_FREEIPA_HOST_ADMIN_USER}
  fi
}

freeipa_logout () {
  kdestroy -A
}


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
  ipa service-add ${OS_SERVICE_TYPE}/${OS_SERVICE}.${OS_DOMAIN}
}

freeipa_update_service_vault () {
  SERVICE=$1
  SERVICE_TYPE=$2
  VAULT_PASSWORD_FILE=$3

  check_required_vars SERVICE \
                      SERVICE_TYPE \
                      VAULT_PASSWORD_FILE

  ipa vault-show --service ${SERVICE_TYPE}/${SERVICE}.${OS_DOMAIN} ${SERVICE} || \
  ipa vault-add ${SERVICE} --service ${SERVICE_TYPE}/${SERVICE}.${OS_DOMAIN} --type symmetric --password-file ${VAULT_PASSWORD_FILE}
}

freeipa_update_service_ca () {
  SERVICE=$1
  LOCATION=$2

  check_required_vars SERVICE \
                      LOCATION \
                      OS_SERVICE_LOCALITY \
                      OS_SERVICE_PLATFORM

  OS_SERVICE_CA_NAME="$(echo ${LOCATION}-${SERVICE} | tr '[:upper:]' '[:lower:]' )"
  OS_SERVICE_CA_CN="${OS_SERVICE_LOCALITY} ${LOCATION} ${SERVICE^} CA"
  OS_SERVICE_CA_ORG="$(echo ${OS_DOMAIN} | tr '[:lower:]' '[:upper:]' )"
  OS_SERVICE_CA_DESC="${OS_SERVICE_PLATFORM} ${OS_SERVICE_LOCALITY} ${LOCATION} ${SERVICE^} CA"

  ipa ca-show ${OS_SERVICE_CA_NAME} || ipa ca-add ${OS_SERVICE_CA_NAME} --subject "CN=${OS_SERVICE_CA_CN}, O=${OS_SERVICE_CA_ORG}" --desc "${OS_SERVICE_CA_DESC}"

  OS_SERVICE_DEFAULT_CA_ACL_NAME=${OS_SERVICE_CA_NAME}
  OS_SERVICE_DEFAULT_CA_ACL_PROFILE=caIPAserviceCert
  ipa caacl-show ${OS_SERVICE_DEFAULT_CA_ACL_NAME} || ipa caacl-add ${OS_SERVICE_DEFAULT_CA_ACL_NAME} --hostcat=all
  ipa caacl-add-profile ${OS_SERVICE_DEFAULT_CA_ACL_NAME} --certprofile ${OS_SERVICE_DEFAULT_CA_ACL_PROFILE} || true
  ipa caacl-add-ca ${OS_SERVICE_DEFAULT_CA_ACL_NAME} --ca ${OS_SERVICE_CA_NAME} || true

}



freeipa_request_service_certs () {
  SVC_HOST_NAME=$1
  SVC_HOST_TYPE=$2
  CERT_BASE=/data/$1
  KUBE_NAMESPACE=$1
  check_required_vars SVC_HOST_NAME \
                      SVC_HOST_TYPE \
                      CERT_BASE \
                      KUBE_NAMESPACE \
                      OS_SERVICE_PLATFORM

  mkdir -p ${CERT_BASE}
  ipa-getcert request -r \
  -f ${CERT_BASE}/${SVC_HOST_TYPE}-${SVC_HOST_NAME}.crt \
  -k ${CERT_BASE}/${SVC_HOST_TYPE}-${SVC_HOST_NAME}.key \
  -F ${CERT_BASE}/${SVC_HOST_TYPE}-${SVC_HOST_NAME}-ca.crt \
  -N "CN=${SVC_HOST_NAME}.${OS_DOMAIN}" \
  -D "${SVC_HOST_NAME}.${OS_DOMAIN}" \
  -D "${SVC_HOST_NAME}.${KUBE_NAMESPACE}.svc.${OS_DOMAIN}" \
  -D "*.${KUBE_NAMESPACE}.pod.${OS_DOMAIN}" \
  -K "${SVC_HOST_TYPE}/${SVC_HOST_NAME}.${OS_DOMAIN}"
}




freeipa_login

freeipa_update_dns $OS_SERVICE $OS_SERVICE_IP
freeipa_update_host $OS_SERVICE

freeipa_update_service $OS_SERVICE_TYPE $OS_SERVICE

freeipa_update_service_vault $OS_SERVICE $OS_SERVICE_TYPE $OS_SERVICE_VAULT_PASSWORD_FILE

freeipa_update_service_ca $OS_SERVICE $OS_SERVICE_LOCATION

freeipa_get_service_certs $OS_SERVICE $OS_SERVICE_LOCATION
freeipa_request_service_certs $OS_SERVICE $OS_SERVICE_TYPE


freeipa_logout
