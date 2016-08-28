#!/bin/bash

# Copyright 2016 Port Direct
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

FREEIPA_LOGIN_METHOD=password

export OS_SERVICE_VAULT_PASSWORD_FILE=/tmp/vault-password
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
