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
echo "${OS_DISTRO}: Starting Postgresql Container"
################################################################################
source /etc/os-container.env
: ${DATADIR:="/var/lib/postgresql/data"}
: ${DB_PORT:="5432"}
OS_DOMAIN=$OS_DOMAIN
ROOT_DB_NAME=${!ROOT_DB_NAME}
ROOT_DB_USER=${!ROOT_DB_USER}
ROOT_DB_PASSWORD=${!ROOT_DB_PASSWORD}
DB_PORT=$DB_PORT
source /opt/harbor/harbor-vars.sh
source /opt/harbor/service-hosts.sh
source /opt/harbor/harbor-common.sh


################################################################################
check_required_vars OS_DOMAIN \
                    DB_PORT \
                    MY_IP


################################################################################
chown -R postgres "$DATADIR"
echo "${OS_DISTRO}: Configuring connections"
sed -ri "s/^#(listen_addresses\s*=\s*)\S+/\1${MY_IP}/" "$DATADIR"/postgresql.conf
sed -ri "s/^#(port\s*=\s*)\S+/\1${DB_PORT}/" "$DATADIR"/postgresql.conf


if [ -z "$(ls -A "$DATADIR")" ]; then

    check_required_vars ROOT_DB_USER \
                        ROOT_DB_NAME \
                        ROOT_DB_PASSWORD

    echo "${OS_DISTRO}: Bootstrapping Postgresql DB in ${DATADIR}"
    su -s /bin/sh -c "initdb" postgres



    if [ "$ROOT_DB_NAME" != 'postgres' ]; then
      createSql="CREATE DATABASE $ROOT_DB_NAME;"
      su -s /bin/bash -c "echo \"$createSql\" | postgres --single -jE" postgres
    fi

    if [ "$ROOT_DB_USER" != 'postgres' ]; then
      op=CREATE
    else
      op=ALTER
    fi

    pass="PASSWORD '$ROOT_DB_PASSWORD'"
    authMethod=md5

    userSql="$op USER $ROOT_DB_USER WITH SUPERUSER $pass;"
    su -s /bin/sh -c "echo \"$userSql\" | postgres --single -jE" postgres

    # internal start of server in order to allow set-up using psql-client
    # does not listen on TCP/IP and waits until start finishes
    su -s /bin/sh -c "pg_ctl -D \"$DATADIR\" \
        -o \"-c listen_addresses=''\" \
        -w start" postgres

    su -s /bin/sh -c "pg_ctl -D \"$DATADIR\" -m fast -w stop" postgres

    cat /opt/harbor/postgresql/pg_hba.conf > $DATADIR/pg_hba.conf
    echo "host all all 0.0.0.0/0 $authMethod" >> $DATADIR/pg_hba.conf
fi



################################################################################
exec su -s /bin/sh -c "exec postgres $@" postgres
