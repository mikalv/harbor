#!/bin/bash
source /etc/os-container.env
export OS_DOMAIN=$(hostname -d)
source /etc/os-container.env
source /opt/harbor/harbor-common.sh
source /opt/harbor/service-hosts.sh
source /opt/harbor/freeipa-login-helper.sh

source /opt/harbor/marina/load-config-helper.sh
load_network_config

load_auth_config_into_vault () {
  SERVICE=$@
  for CONF_SECTION in ${SERVICE}; do
    if [ "${CONF_SECTION}" = "DEFAULT" ]; then
      DEBUG=$(crudini --get $cfg_harbor_auth ${CONF_SECTION} debug)
      HARBOR_ROLES=$(crudini --get $cfg_harbor_auth ${CONF_SECTION} roles)
      LOCAL_ENV_LIST="${LOCAL_ENV_LIST} DEBUG HARBOR_ROLES"
      echo "DEBUG=${DEBUG}" > ${LOCAL_ENV}
      source ${LOCAL_ENV}
      rm -f ${LOCAL_ENV}
      echo "HARBOR_ROLES=${HARBOR_ROLES}" > ${LOCAL_ENV}
      source ${LOCAL_ENV}
      rm -f ${LOCAL_ENV}
    else
        HARBOR_VAULT_ACTIVE=$(crudini --get $cfg_harbor_auth ${CONF_SECTION} harbor_auth_vault || echo "Prime")
        if [ "$HARBOR_VAULT_ACTIVE" == "Prime" ]; then
          for COMPONENT in $(crudini --get $cfg_harbor_auth ${CONF_SECTION}); do
            VALUE="$(crudini --get $cfg_harbor_auth ${CONF_SECTION} ${COMPONENT})"
            if [ "$CONF_SECTION" == "freeipa" ]; then
              echo "$CONF_SECTION - leaving config params on host"
            else
              crudini --del $cfg_harbor_auth ${CONF_SECTION} ${COMPONENT}
            fi
            NAME="$(echo AUTH_${CONF_SECTION}_${COMPONENT} | tr '[:lower:]' '[:upper:]')"
            LOCAL_ENV_LIST="${LOCAL_ENV_LIST} ${NAME}"
            echo "${NAME}=${VALUE}" > ${LOCAL_ENV}
            source ${LOCAL_ENV}
            rm -f ${LOCAL_ENV}
          done
          if [ "$CONF_SECTION" == "freeipa" ]; then
            if [ "$CURRENT_AUTH_SERVICE" == "$CONF_SECTION-master" ]; then
              echo "not filering auth section as freeipa"
              VAULT_NAME="env-${CONF_SECTION}-master"
              crudini --set $cfg_harbor_auth ${CONF_SECTION}-master harbor_auth_vault "True"
              crudini --set $cfg_harbor_auth ${CONF_SECTION}-master harbor_auth_vault_name "${VAULT_NAME}"
              crudini --get $cfg_harbor_auth ${CONF_SECTION}-master harbor_auth_vault_user || \
                crudini --set $cfg_harbor_auth ${CONF_SECTION}-master harbor_auth_vault_user "${FREEIPA_HOST_ADMIN_USER}"
              crudini --get $cfg_harbor_auth ${CONF_SECTION}-master harbor_auth_vault_password || \
                crudini --set $cfg_harbor_auth ${CONF_SECTION}-master harbor_auth_vault_password "$(pwgen $((64 + RANDOM % 32)) 1)"
            elif [ "$CURRENT_AUTH_SERVICE" == "$CONF_SECTION-user" ]; then
              VAULT_NAME="env-${CONF_SECTION}-user"
              crudini --set $cfg_harbor_auth ${CONF_SECTION}-user harbor_auth_vault "True"
              crudini --set $cfg_harbor_auth ${CONF_SECTION}-user harbor_auth_vault_name "${VAULT_NAME}"
              crudini --get $cfg_harbor_auth ${CONF_SECTION}-user harbor_auth_vault_user || \
                crudini --set $cfg_harbor_auth ${CONF_SECTION}-user harbor_auth_vault_user "${FREEIPA_HOST_ADMIN_USER}"
              crudini --get $cfg_harbor_auth ${CONF_SECTION}-user harbor_auth_vault_password || \
                crudini --set $cfg_harbor_auth ${CONF_SECTION}-user harbor_auth_vault_password "$(pwgen $((64 + RANDOM % 32)) 1)"
            elif [ "$CURRENT_AUTH_SERVICE" == "$CONF_SECTION-host" ]; then
              VAULT_NAME="env-${CONF_SECTION}-host"
              crudini --set $cfg_harbor_auth ${CONF_SECTION}-host harbor_auth_vault "True"
              crudini --set $cfg_harbor_auth ${CONF_SECTION}-host harbor_auth_vault_name "${VAULT_NAME}"
              crudini --get $cfg_harbor_auth ${CONF_SECTION}-host harbor_auth_vault_user || \
                crudini --set $cfg_harbor_auth ${CONF_SECTION}-host harbor_auth_vault_user "${FREEIPA_HOST_ADMIN_USER}"
              crudini --get $cfg_harbor_auth ${CONF_SECTION}-host harbor_auth_vault_password || \
                crudini --set $cfg_harbor_auth ${CONF_SECTION}-host harbor_auth_vault_password "$(pwgen $((64 + RANDOM % 32)) 1)"
            else
              VAULT_NAME="env-${CONF_SECTION}"
              crudini --set $cfg_harbor_auth ${CONF_SECTION} harbor_auth_vault "True"
              crudini --set $cfg_harbor_auth ${CONF_SECTION} harbor_auth_vault_name "${VAULT_NAME}"
              crudini --get $cfg_harbor_auth ${CONF_SECTION} harbor_auth_vault_user || \
                crudini --set $cfg_harbor_auth ${CONF_SECTION} harbor_auth_vault_user "${FREEIPA_HOST_ADMIN_USER}"
              crudini --get $cfg_harbor_auth ${CONF_SECTION} harbor_auth_vault_password || \
                crudini --set $cfg_harbor_auth ${CONF_SECTION} harbor_auth_vault_password "$(pwgen $((64 + RANDOM % 32)) 1)"
            fi
          else
            VAULT_NAME="env-${CONF_SECTION}"
            crudini --set $cfg_harbor_auth ${CONF_SECTION} harbor_auth_vault "True"
            crudini --set $cfg_harbor_auth ${CONF_SECTION} harbor_auth_vault_name "${VAULT_NAME}"
            crudini --get $cfg_harbor_auth ${CONF_SECTION} harbor_auth_vault_user || \
              crudini --set $cfg_harbor_auth ${CONF_SECTION} harbor_auth_vault_user "${FREEIPA_HOST_ADMIN_USER}"
            crudini --get $cfg_harbor_auth ${CONF_SECTION} harbor_auth_vault_password || \
              crudini --set $cfg_harbor_auth ${CONF_SECTION} harbor_auth_vault_password "$(pwgen $((64 + RANDOM % 32)) 1)"
          fi
        fi
    fi;
  done
}


freeipa_create_service_env_vault () {
  CURRENT_AUTH_SERVICE=$1
  VAULT_PASSWORD_FILE=$2
  AUTH_SECTION=$3

  check_required_vars CURRENT_AUTH_SERVICE \
                      VAULT_PASSWORD_FILE \
                      AUTH_SECTION \
                      OS_DOMAIN \
                      FREEIPA_HOST_ADMIN_USER

  export CURRENT_AUTH_SERVICE
  LOCAL_ENV_LIST=""
  if [ "$CURRENT_AUTH_SERVICE" == "freeipa-master" ]; then
    echo "not filering auth section as freeipa"
    load_auth_config_into_vault ${AUTH_SECTION}
    export LOCAL_ENV_LIST=$(echo $LOCAL_ENV_LIST | xargs -n1 | sort -u)
  elif [ "$CURRENT_AUTH_SERVICE" == "freeipa-user" ]; then
    load_auth_config_into_vault ${AUTH_SECTION}
    export LOCAL_ENV_LIST=$(echo $LOCAL_ENV_LIST | grep -o '\bAUTH_FREEIPA_USER\w*' | xargs -n1 | sort -u)
  elif [ "$CURRENT_AUTH_SERVICE" == "freeipa-host" ]; then
    load_auth_config_into_vault ${AUTH_SECTION}
    export LOCAL_ENV_LIST=$(echo $LOCAL_ENV_LIST | grep -o '\bAUTH_FREEIPA_HOST\w*' | xargs -n1 | sort -u)
  else
    load_auth_config_into_vault ${AUTH_SECTION}
    export LOCAL_ENV_LIST=$(echo $LOCAL_ENV_LIST | sed 's/AUTH_FREEIPA[^ ]*//g' | xargs -n1 | sort -u)
  fi

  if [ -z "${LOCAL_ENV_LIST}" ]; then
    echo "No Variables to archive"
  else
    LOCAL_VAULT_NAME="$(crudini --get $cfg_harbor_auth ${CURRENT_AUTH_SERVICE} harbor_auth_vault_name)"
    LOCAL_VAULT_PASSWORD_FILE=/tmp/local-vault-password
    LOCAL_VAULT_USER="$(crudini --get $cfg_harbor_auth ${CURRENT_AUTH_SERVICE} harbor_auth_vault_user)"
    crudini --get $cfg_harbor_auth ${CURRENT_AUTH_SERVICE} harbor_auth_vault_password > $LOCAL_VAULT_PASSWORD_FILE

    ipa vault-show --user ${LOCAL_VAULT_USER} ${LOCAL_VAULT_NAME} || \
    ipa vault-add ${LOCAL_VAULT_NAME} --user ${LOCAL_VAULT_USER} --type symmetric --password-file ${LOCAL_VAULT_PASSWORD_FILE}

    FILE=/tmp/env-var
    rm -f ${FILE}
    touch ${FILE}
    for ENV_VAR in $LOCAL_ENV_LIST; do
      echo "$ENV_VAR=${!ENV_VAR}" >>  ${FILE}
    done

    ipa vault-archive ${LOCAL_VAULT_NAME} \
    --user ${LOCAL_VAULT_USER} \
    --password-file ${LOCAL_VAULT_PASSWORD_FILE} \
    --in ${FILE}

    rm -f ${FILE}
    rm -f $LOCAL_VAULT_PASSWORD_FILE
  fi
}


freeipa_login
for OS_AUTH_CFG_SECTION in $(crudini --get $cfg_harbor_auth); do
  if [ "$OS_AUTH_CFG_SECTION" == "freeipa" ]; then
    for OS_AUTH_SUB_CFG_SECTION in freeipa-master freeipa-user freeipa-host; do
      freeipa_create_service_env_vault ${OS_AUTH_SUB_CFG_SECTION} $OS_SERVICE_VAULT_PASSWORD_FILE ${OS_AUTH_CFG_SECTION}
    done
  else
    freeipa_create_service_env_vault ${OS_AUTH_CFG_SECTION} $OS_SERVICE_VAULT_PASSWORD_FILE ${OS_AUTH_CFG_SECTION}
  fi
done
freeipa_logout
