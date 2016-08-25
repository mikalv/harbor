#!/bin/sh
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
            echo "$CONF_SECTION - leaving config params on host"
          else
            VAULT_NAME="env-${CONF_SECTION}"
            crudini --set $cfg_harbor_auth ${CONF_SECTION} harbor_auth_vault "True"
            crudini --set $cfg_harbor_auth ${CONF_SECTION} harbor_auth_vault_name "${VAULT_NAME}"
            crudini --set $cfg_harbor_auth ${CONF_SECTION} harbor_auth_vault_user "${FREEIPA_HOST_ADMIN_USER}"
            crudini --set $cfg_harbor_auth ${CONF_SECTION} harbor_auth_vault_password "$(cat ${VAULT_PASSWORD_FILE})"
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
    VAULT_NAME="env-${CURRENT_AUTH_SERVICE}"
    ipa vault-show --user ${FREEIPA_HOST_ADMIN_USER} ${VAULT_NAME} || \
    ipa vault-add ${VAULT_NAME} --user ${FREEIPA_HOST_ADMIN_USER} --type symmetric --password-file ${VAULT_PASSWORD_FILE}

    FILE=/tmp/env-var
    rm -f ${FILE}
    touch ${FILE}
    for ENV_VAR in $LOCAL_ENV_LIST; do
      echo "$ENV_VAR=${!ENV_VAR}" >>  ${FILE}
    done
    ipa vault-archive ${VAULT_NAME} \
    --user ${FREEIPA_HOST_ADMIN_USER} \
    --password-file ${VAULT_PASSWORD_FILE} \
    --in ${FILE}
    rm -f ${FILE}
  fi
}


freeipa_login
freeipa_create_service_env_vault freeipa-user $OS_SERVICE_VAULT_PASSWORD_FILE freeipa
freeipa_create_service_env_vault freeipa-host $OS_SERVICE_VAULT_PASSWORD_FILE freeipa
for OS_AUTH_CFG_SECTION in $(crudini --get $cfg_harbor_auth | sed 's/^freeipa$//g'); do
      freeipa_create_service_env_vault ${OS_AUTH_CFG_SECTION} $OS_SERVICE_VAULT_PASSWORD_FILE ${OS_AUTH_CFG_SECTION}
done
freeipa_logout
