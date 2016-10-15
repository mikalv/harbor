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
echo "${OS_DISTRO}: Bootstrapping database"
################################################################################
. /etc/os-container.env
. /opt/harbor/service-hosts.sh
. /opt/harbor/harbor-common.sh
. /opt/harbor/gnocchi/vars.sh


################################################################################
check_required_vars OS_DOMAIN \
                    GRAFANA_DB_SERVICE_HOST_SVC \
                    GRAFANA_DB_SERVICE_PORT \
                    GRAFANA_DB_CA \
                    GRAFANA_DB_KEY \
                    GRAFANA_DB_CERT \
                    GRAFANA_DATABASES


echo "${OS_DISTRO}: Managing Databases"
################################################################################
pgsql_superuser_cmd () {
  DB_COMMAND="$@"

  ################################
  check_required_vars AUTH_GNOCCHI_GRAFANA_DB_ROOT_USER \
                      AUTH_GNOCCHI_GRAFANA_DB_ROOT_PASSWORD \
                      GRAFANA_DB_SERVICE_HOST_SVC \
                      GRAFANA_DB_SERVICE_PORT \
                      DB_COMMAND

  ################################
  export PGPASSWORD=$AUTH_GNOCCHI_GRAFANA_DB_ROOT_PASSWORD
  psql \
  --host ${GRAFANA_DB_SERVICE_HOST_SVC} \
  --port=${GRAFANA_DB_SERVICE_PORT} \
  --username=${AUTH_GNOCCHI_GRAFANA_DB_ROOT_USER} \
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
  GRAFANA_DB_LIST=$1

  ################################
  check_required_vars GRAFANA_DB_LIST

  ################################
  for GRAFANA_DATABASE in ${GRAFANA_DATABASES}; do
    DB_NAME_VAR="AUTH_GNOCCHI_GRAFANA_${GRAFANA_DATABASE}_NAME"
    DB_USER_VAR="AUTH_GNOCCHI_GRAFANA_${GRAFANA_DATABASE}_USER"
    DB_PASSWORD_VAR="AUTH_GNOCCHI_GRAFANA_${GRAFANA_DATABASE}_PASSWORD"
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

ipsilon_manage_dbs "${GRAFANA_DATABASES}"
