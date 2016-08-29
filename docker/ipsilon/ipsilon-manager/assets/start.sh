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
tail -f /dev/null
set -e
echo "${OS_DISTRO}: Ipsilon Management Starting"
################################################################################
. /etc/os-container.env
. /opt/harbor/service-hosts.sh
. /opt/harbor/harbor-common.sh
: ${IPSILON_DB_SERVICE_PORT:="5432"}
: ${IPSILON_DB_CA:="/run/harbor/auth/user/ca"}
: ${IPSILON_DB_KEY:="/run/harbor/auth/user/key"}
: ${IPSILON_DB_CERT:="/run/harbor/auth/user/crt"}
: ${IPSILON_DB_SERVICE_HOST_SVC:="${IPSILON_HOSTNAME}-db.${IPSILON_SERVICE_NAMESPACE}.svc.$OS_DOMAIN"}
: ${IPSILON_DATABASES:="DB ADMIN_DB USERS_DB TRANS_DB SAML2SESSION_DB SAMLSESSION_DB OPENID_DB OPENIDC_DB"}

IPSILON_DATABASES="DB ADMIN_DB USERS_DB TRANS_DB SAML2SESSION_DB SAMLSESSION_DB OPENID_DB OPENIDC_DB"
################################################################################
check_required_vars OS_DOMAIN \
                    IPSILON_HOSTNAME \
                    IPSILON_SERVICE_NAMESPACE \
                    IPSILON_DB_SERVICE_HOST_SVC \
                    IPSILON_DB_SERVICE_PORT \
                    IPSILON_DB_CA \
                    IPSILON_DB_KEY \
                    IPSILON_DB_CERT \
                    IPSILON_DATABASES


echo "${OS_DISTRO}: Managing Databases"
################################################################################
pgsql_superuser_cmd () {
  DB_COMMAND="$@"

  ################################
  check_required_vars AUTH_IPSILON_DB_ROOT_USER \
                      AUTH_IPSILON_DB_ROOT_PASSWORD \
                      IPSILON_DB_SERVICE_HOST_SVC \
                      IPSILON_DB_SERVICE_PORT \
                      DB_COMMAND

  ################################
  export PGPASSWORD=$AUTH_IPSILON_DB_ROOT_PASSWORD
  psql \
  --host ${IPSILON_DB_SERVICE_HOST_SVC} \
  --port=${IPSILON_DB_SERVICE_PORT} \
  --username=${AUTH_IPSILON_DB_ROOT_USER} \
  --command="${DB_COMMAND}"
  export PGPASSWORD=''
}

pgsql_create_db () {
  DB_NAME=$1

  ################################
  check_required_vars DB_NAME

  ################################
  pgsql_superuser_cmd "SELECT 1 FROM pg_database WHERE datname = '$DB_NAME'" | grep -q 1 || pgsql_superuser_cmd "CREATE DATABASE $DB_NAME"
}

pgsql_create_db_user () {
  USER_NAME=$1
  USER_PASSWORD=$2

  ################################
  check_required_vars USER_NAME \
                      USER_PASSWORD

  ################################
  pgsql_superuser_cmd "SELECT * FROM pg_roles WHERE rolname = '$USER_NAME';" | tail -n +3 | head -n -2 | grep -q 1 || \
    pgsql_superuser_cmd "CREATE ROLE $USER_NAME LOGIN PASSWORD '$USER_PASSWORD';"
}

pgsql_assign_db_user () {
  USER_NAME=$1
  USER_DATABASE=$2

  ################################
  check_required_vars USER_NAME \
                      USER_DATABASE

  ################################
  pgsql_superuser_cmd "GRANT ALL PRIVILEGES ON DATABASE $USER_DATABASE to $USER_NAME;"
}

pgsql_manage_db () {
  USER_DATABASE=$1
  USER_NAME=$2
  USER_PASSWORD=$3

  ################################
  check_required_vars USER_DATABASE \
                      USER_NAME \
                      USER_PASSWORD

  ################################
  pgsql_create_db ${USER_DATABASE}
  pgsql_create_db_user ${USER_NAME} ${USER_PASSWORD}
  pgsql_assign_db_user ${USER_NAME} ${USER_DATABASE}
}


ipsilon_manage_dbs () {
  IPSILON_DB_LIST=$1

  ################################
  check_required_vars IPSILON_DB_LIST

  ################################
  for IPSILON_DATABASE in ${IPSILON_DATABASES}; do
    DB_NAME_VAR="AUTH_IPSILON_${IPSILON_DATABASE}_NAME"
    DB_USER_VAR="AUTH_IPSILON_${IPSILON_DATABASE}_USER"
    DB_PASSWORD_VAR="AUTH_IPSILON_${IPSILON_DATABASE}_PASSWORD"
    CURRENT_DB_NAME="$(echo ${!DB_NAME_VAR})"
    CURRENT_DB_USER="$(echo ${!DB_USER_VAR})"
    CURRENT_DB_PASSWORD="$(echo ${!DB_PASSWORD_VAR})"

    ################################
    check_required_vars CURRENT_DB_NAME \
                        CURRENT_DB_USER \
                        CURRENT_DB_PASSWORD


    echo "${OS_DISTRO}: Setting up ${CURRENT_DB_NAME} database for ${CURRENT_DB_USER}"
    ################################
    pgsql_manage_db ${CURRENT_DB_NAME} ${CURRENT_DB_USER} ${CURRENT_DB_PASSWORD}
  done
}

ipsilon_manage_dbs "${IPSILON_DATABASES}"


echo "${OS_DISTRO}: Installing Ipsilon"
################################################################################
. /etc/os-container.env
. /opt/harbor/service-hosts.sh
. /opt/harbor/harbor-common.sh
: ${IPSILON_DB_SERVICE_PORT:="5432"}
: ${IPSILON_DB_CA:="/run/harbor/auth/user/ca"}
: ${IPSILON_DB_KEY:="/run/harbor/auth/user/key"}
: ${IPSILON_DB_CERT:="/run/harbor/auth/user/crt"}
: ${IPSILON_DB_SERVICE_HOST_SVC:="${IPSILON_HOSTNAME}-db.${IPSILON_SERVICE_NAMESPACE}.svc.$OS_DOMAIN"}
: ${IPSILON_DATABASES:="DB ADMIN_DB USERS_DB TRANS_DB SAML2SESSION_DB SAMLSESSION_DB OPENID_DB OPENIDC_DB"}


################################################################################
check_required_vars OS_DOMAIN \
                    IPSILON_HOSTNAME \
                    IPSILON_SERVICE_NAMESPACE \
                    IPSILON_DB_SERVICE_HOST_SVC \
                    IPSILON_DB_SERVICE_PORT \
                    IPSILON_DB_CA \
                    IPSILON_DB_KEY \
                    IPSILON_DB_CERT \
                    IPSILON_DATABASES \
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
cat /etc/ipa/ca.crt >> /etc/ssl/certs/ca-bundle.crt

if [ -f /var/lib/ipsilon/installed ] ; then
  rm -rf /var/lib/ipsilon/idp
  mkdir -p /var/lib/ipsilon/idp/saml2
  cp /var/lib/ipsilon/idp-live/saml2/* /var/lib/ipsilon/idp/saml2/
  echo "${AUTH_FREEIPA_HOST_ADMIN_USER}" | kinit "${AUTH_FREEIPA_HOST_ADMIN_USER}"
  ipsilon-server-install \
      --hostname ${IPSILON_SERVICE_HOST} \
      --ipa=yes \
      --gssapi=yes \
      --form=yes \
      --info-sssd=yes \
      --admin-user=${IPA_HOST_ADMIN_USER}
  rm -rf /etc/ipsilon
  rm -rf /var/lib/ipsilon/idp
  ln -s /var/lib/ipsilon/etc /etc/ipsilon
  ln -s /var/lib/ipsilon/idp-live /var/lib/ipsilon/idp
else
  rm -rf /etc/ipsilon
  mkdir -p /var/lib/ipsilon/etc
  ln -s /var/lib/ipsilon/etc /etc/ipsilon
  echo "${AUTH_FREEIPA_HOST_ADMIN_PASSWORD}" | kinit "${AUTH_FREEIPA_HOST_ADMIN_USER}"
  ipsilon-server-install \
      --hostname ${IPSILON_SERVICE_HOST} \
      --ipa=yes \
      --gssapi=yes \
      --form=yes \
      --info-sssd=yes \
      --admin-user=${AUTH_FREEIPA_HOST_ADMIN_USER} \
      --admin-dburi=postgres://${AUTH_IPSILON_ADMIN_DB_USER}:${AUTH_IPSILON_ADMIN_DB_PASSWORD}@${IPSILON_DB_SERVICE_HOST_SVC}/${AUTH_IPSILON_ADMIN_DB_NAME} \
      --users-dburi=postgres://${AUTH_IPSILON_USERS_DB_USER}:${AUTH_IPSILON_USERS_DB_PASSWORD}@${IPSILON_DB_SERVICE_HOST_SVC}/${AUTH_IPSILON_USERS_DB_NAME} \
      --transaction-dburi=postgres://${AUTH_IPSILON_TRANS_DB_USER}:${AUTH_IPSILON_TRANS_DB_PASSWORD}@${IPSILON_DB_SERVICE_HOST_SVC}/${AUTH_IPSILON_TRANS_DB_NAME}
  mv /var/lib/ipsilon/idp /var/lib/ipsilon/idp-live
  ln -s /var/lib/ipsilon/idp-live /var/lib/ipsilon/idp
  touch /var/lib/ipsilon/installed
fi

[global]
debug = False
tools.log_request_response.on = False
template_dir = "templates"
cache_dir = "/var/cache/ipsilon"
cleanup_interval = 30
db.conn.log = False
db.echo = False

base.mount = "/idp"
base.dir = "/usr/share/ipsilon"
IPSILON_CONFIG_FILE=/etc/ipsilon/idp/ipsilon.conf
crudini --set ${IPSILON_CONFIG_FILE} global admin.config.db "'postgres://${AUTH_IPSILON_ADMIN_DB_USER}:${AUTH_IPSILON_ADMIN_DB_PASSWORD}@${IPSILON_DB_SERVICE_HOST_SVC}/${AUTH_IPSILON_ADMIN_DB_NAME}'"
crudini --set ${IPSILON_CONFIG_FILE} global user.prefs.db "'postgres://${AUTH_IPSILON_USERS_DB_USER}:${AUTH_IPSILON_USERS_DB_PASSWORD}@${IPSILON_DB_SERVICE_HOST_SVC}/${AUTH_IPSILON_USERS_DB_NAME}'"
crudini --set ${IPSILON_CONFIG_FILE} global transactions.db "'postgres://${AUTH_IPSILON_TRANS_DB_USER}:${AUTH_IPSILON_TRANS_DB_PASSWORD}@${IPSILON_DB_SERVICE_HOST_SVC}/${AUTH_IPSILON_TRANS_DB_NAME}'"

crudini --set ${IPSILON_CONFIG_FILE} global admin.config.db "'sqlite:////var/lib/ipsilon/idp/adminconfig.sqlite'"
crudini --set ${IPSILON_CONFIG_FILE} global user.prefs.db "'sqlite:////var/lib/ipsilon/idp/userprefs.sqlite'"
crudini --set ${IPSILON_CONFIG_FILE} global transactions.db "'sqlite:////var/lib/ipsilon/idp/transactions.sqlite'"


admin.config.db = "postgres://ipsilon_admin:quae9eeCh6baeZio@ipsilon-db.os-ipsilon.svc.novalocal/ipsilon_admin"
user.prefs.db = "sqlite:////var/lib/ipsilon/idp/userprefs.sqlite"
transactions.db = "sqlite:////var/lib/ipsilon/idp/transactions.sqlite"

tools.sessions.on = True
tools.sessions.name = "idp_ipsilon_session_id"
tools.sessions.storage_type = "file"
tools.sessions.storage_path = "/var/lib/ipsilon/idp/sessions"
tools.sessions.path = "/idp"
tools.sessions.timeout = 60
tools.sessions.httponly = True
tools.sessions.secure = True


\
--samlsessions-dburi=postgres://${AUTH_IPSILON_SAMLSESSION_DB_USER}:${AUTH_IPSILON_SAMLSESSION_DB_PASSWORD}@${IPSILON_DB_SERVICE_HOST_SVC}/${AUTH_IPSILON_SAMLSESSION_DB_NAME} \
--saml2-session-dburl=postgres://${AUTH_IPSILON_SAML2SESSION_DB_USER}:${AUTH_IPSILON_SAML2SESSION_DB_PASSWORD}@${IPSILON_DB_SERVICE_HOST_SVC}/${AUTH_IPSILON_SAML2SESSION_DB_NAME}

export PGPASSWORD=${AUTH_IPSILON_USERS_DB_PASSWORD}
psql \
--host ${IPSILON_DB_SERVICE_HOST_SVC} \
--port=${IPSILON_DB_SERVICE_PORT} \
--username=${AUTH_IPSILON_USERS_DB_USER} \
${AUTH_IPSILON_USERS_DB_NAME}
export PGPASSWORD=''
