#!/bin/bash
FREEIPA_HOST_ADMIN_USER=admin
FREEIPA_LOGIN_METHOD=password

export OS_SERVICE_VAULT_PASSWORD_FILE=/tmp/vault-password
echo "password123" > $OS_SERVICE_VAULT_PASSWORD_FILE

freeipa_login () {
  check_required_vars FREEIPA_LOGIN_METHOD
  if [ "$FREEIPA_LOGIN_METHOD" == 'keytab' ]; then
    kinit -k -t /etc/krb5.keytab
  elif [ "$FREEIPA_LOGIN_METHOD" == 'password' ]; then
    check_required_vars FREEIPA_HOST_ADMIN_PASSWORD FREEIPA_HOST_ADMIN_USER
    echo ${FREEIPA_HOST_ADMIN_PASSWORD} | kinit ${FREEIPA_HOST_ADMIN_USER}
  fi
}

freeipa_logout () {
  kdestroy -A
}
