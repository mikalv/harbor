#!/bin/sh
source /etc/os-container.env
export OS_DOMAIN=$(hostname -d)
source /etc/os-container.env
source /opt/harbor/harbor-common.sh
source /opt/harbor/service-hosts.sh
source /opt/harbor/freeipa-login-helper.sh
source /opt/harbor/marina/load-config-helper.sh
source /opt/harbor/marina/manifest-helper.sh

freeipa_get_service_env_vault () {
  OS_SERVICE=$1
  VAULT_PASSWORD_FILE=$2
  AUTH_SECTION=$3
  ENV_FILE=$4

  check_required_vars OS_SERVICE \
                      VAULT_PASSWORD_FILE \
                      AUTH_SECTION \
                      OS_DOMAIN


    HARBOR_VAULT_ACTIVE=$(crudini --get $cfg_harbor_auth ${AUTH_SECTION} harbor_auth_vault || echo "False")
    FILE=/tmp/env-var
    if [ "$HARBOR_VAULT_ACTIVE" == "True" ]; then
      PASSWD_FILE=/tmp/env-var-password
      echo "$(crudini --get $cfg_harbor_auth ${AUTH_SECTION} harbor_auth_vault_password)" > ${PASSWD_FILE}
      VAULT_USER=$(crudini --get $cfg_harbor_auth ${AUTH_SECTION} harbor_auth_vault_user)
      VAULT_NAME=$(crudini --get $cfg_harbor_auth ${AUTH_SECTION} harbor_auth_vault_name)
      ipa vault-retrieve ${VAULT_NAME} \
      --user ${VAULT_USER} \
      --password-file ${PASSWD_FILE} \
      --out ${FILE}
      rm -f ${PASSWD_FILE}
      cat ${FILE} >> ${ENV_FILE}
      rm -f ${FILE}
    else
        for COMPONENT in $(crudini --get $cfg_harbor_auth ${AUTH_SECTION}); do
              VALUE="$(crudini --get $cfg_harbor_auth ${AUTH_SECTION} ${COMPONENT})"
              NAME="$(echo AUTH_${AUTH_SECTION}_${COMPONENT} | tr '[:lower:]' '[:upper:]')"
              echo "${NAME}=${VALUE}" >> ${FILE}
        done
        if [ "$OS_SERVICE" == "freeipa-master" ]; then
          echo "not filering auth section as freeipa"
          cat ${FILE} >> ${ENV_FILE}
        elif [ "$OS_SERVICE" == "freeipa-user" ]; then
          grep -e '^AUTH_FREEIPA_USER' ${FILE} >> ${ENV_FILE}
        elif [ "$OS_SERVICE" == "freeipa-host" ]; then
          grep -e '^AUTH_FREEIPA_HOST' ${FILE} >> ${ENV_FILE}
        else
          grep -e '^AUTH_FREEIPA' ${FILE} >> ${ENV_FILE}
        fi
        rm -f ${FILE}
    fi
}

service_env_build_list_from_file () {
  ENV_FILE=$1
  LOCAL_ENV_LIST=""
  while read ENV_VAR; do
    ENV_VAR_NAME=$(echo $ENV_VAR | awk -F '=' '{ print $1}')
    LOCAL_ENV_LIST="$LOCAL_ENV_LIST $ENV_VAR_NAME"
    echo $LOCAL_ENV_LIST
  done <${ENV_FILE}
  export LOCAL_ENV_LIST
}

freeipa_retreve_all_env_vars () {
  freeipa_login
  rm -rf /tmp/env-vars
  freeipa_get_service_env_vault freeipa-user $OS_SERVICE_VAULT_PASSWORD_FILE freeipa /tmp/env-vars
  freeipa_get_service_env_vault freeipa-host $OS_SERVICE_VAULT_PASSWORD_FILE freeipa /tmp/env-vars
  #freeipa_get_service_env_vault freeipa-master $OS_SERVICE_VAULT_PASSWORD_FILE freeipa /tmp/env-vars

  for OS_AUTH_CFG_SECTION in $(crudini --get $cfg_harbor_auth | sed 's/^freeipa$//g'); do
    freeipa_get_service_env_vault $OS_AUTH_CFG_SECTION $OS_SERVICE_VAULT_PASSWORD_FILE $OS_AUTH_CFG_SECTION /tmp/env-vars
  done
  freeipa_logout
}

load_manifest () {
  KUBE_ADMIN_USER=admin
  KUBE_BASE=/var/lib/harbor/kube
  KUBE_ADMIN_TOKEN=$(cat ${KUBE_BASE}/known_tokens.csv | grep ",$KUBE_ADMIN_USER$" | awk -F ',' '{ print $1 }')

  manifest_group=$1
  manifest=$2.yaml
  MANIFEST_WORK_FILE="$MANIFESTS_WORK_DIR/$manifest_group/$manifest"
  cat $MANIFEST_WORK_FILE
  if [ "$manifest" == "namespace.yaml" ]; then
    echo "Not deleting namespace"
    kubectl --server https://kubernetes.${OS_DOMAIN}:6443 --user=${KUBE_ADMIN_USER} --token=${KUBE_ADMIN_TOKEN} create -f $MANIFEST_WORK_FILE || true
  else
    kubectl --server https://kubernetes.${OS_DOMAIN}:6443 --user=${KUBE_ADMIN_USER} --token=${KUBE_ADMIN_TOKEN} delete -f $MANIFEST_WORK_FILE || true
    kubectl --server https://kubernetes.${OS_DOMAIN}:6443 --user=${KUBE_ADMIN_USER} --token=${KUBE_ADMIN_TOKEN} create -f $MANIFEST_WORK_FILE
  fi;
}


load_network_config
freeipa_retreve_all_env_vars
service_env_build_list_from_file /tmp/env-vars

HARBOR_SERVICE_DEFAULT_DEV=eth0
export NODE_NETWORK_DEFAULT_DEVICE=$HARBOR_SERVICE_DEFAULT_DEV
export NODE_NETWORK_DEFAULT_IP=$HARBOR_SERVICE_DEFAULT_IP
export LOCAL_ENV_LIST="$LOCAL_ENV_LIST NODE_NETWORK_DEFAULT_DEVICE NODE_NETWORK_DEFAULT_IP"
export KUBE_ENDPOINT="http://kubernetes.${OS_DOMAIN}:6443"
export LOCAL_ENV_LIST="$LOCAL_ENV_LIST KUBE_ENDPOINT OS_DOMAIN"
export LOAD_OS_SERVICE=$MARINA_SERVICE

load_image_config ${LOAD_OS_SERVICE}
load_image_config marina
load_network_config

prep_manifests ${LOAD_OS_SERVICE}

load_manifest ${LOAD_OS_SERVICE} namespace
load_manifest ${LOAD_OS_SERVICE} services
load_manifest ${LOAD_OS_SERVICE} controllers
load_manifest ${LOAD_OS_SERVICE} secrets
