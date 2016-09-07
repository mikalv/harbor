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
echo "${OS_DISTRO}: Starting MariaDB Container"
source /etc/os-container.env
: ${DATADIR:=/var/lib/mysql}
: ${DB_PORT:="3306"}
OS_DOMAIN=$OS_DOMAIN
DB_ROOT_PASSWORD=${!DB_ROOT_PASSWORD}
MARIADB_DATABASE=${!MARIADB_DATABASE}
MARIADB_USER=${!MARIADB_USER}
MARIADB_PASSWORD=${!MARIADB_PASSWORD}
DB_NAME=${!DB_NAME}
DB_USER=${!DB_USER}
DB_PASSWORD=${!DB_PASSWORD}
DB_NAME_1=${!DB_NAME_1}
DB_USER_1=${!DB_USER_1}
DB_PASSWORD_1=${!DB_PASSWORD_1}
DB_PORT=$DB_PORT
source /opt/harbor/harbor-vars.sh
source /opt/harbor/service-hosts.sh
source /opt/harbor/harbor-common.sh
check_required_vars OS_DOMAIN \
                    DB_PORT

server_cnf=/etc/mysql/my.cnf
if [ -z "${!DB_TLS}" ]; then
  echo "${OS_DISTRO}: This database supports and requires TLS auth"
  MARIADB_X509="REQUIRE X509"
  sed -i "/\[mysqld\]/a ssl-cipher = TLSv1.2" $server_cnf
  sed -i "/\[mysqld\]/a ssl-ca = ${DB_TLS}/tls.ca" $server_cnf
  sed -i "/\[mysqld\]/a ssl-key = ${DB_TLS}/tls.key" $server_cnf
  sed -i "/\[mysqld\]/a ssl-cert = ${DB_TLS}/tls.crt " $server_cnf
else
  MARIADB_X509=""
fi

echo "${OS_DISTRO}: This database will serve on port: ${DB_PORT}"
sed -i "s/port = 3306/port = ${DB_PORT}/g" $server_cnf

MYSQLD_CMD="mysqld_safe"
if [ -z "$(ls /var/lib/mysql)" -a "${MYSQLD_CMD}" = 'mysqld_safe' ]; then
  echo "${OS_DISTRO}: Prepping MySQL"
  PATH=/usr/libexec:$PATH
  export PATH

  check_required_vars OS_DOMAIN \
                      DB_ROOT_PASSWORD \
                      MARIADB_DATABASE \
                      MARIADB_USER \
                      MARIADB_PASSWORD \
                      DB_NAME \
                      DB_USER \
                      DB_PASSWORD \
                      DB_PORT

  echo "${OS_DISTRO}: Installing Base Schema"
  mysql_install_db --user=mysql --datadir="$DATADIR"

  echo "${OS_DISTRO}: Writing 1st boot script"

  TEMP_FILE='/tmp/mysql-first-time.sql'
  echo "${OS_DISTRO}: Writing 1st boot script: root auth"
  cat > "$TEMP_FILE" <<EOSQL
DELETE FROM mysql.user ;
CREATE OR REPLACE USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}' ;
GRANT ALL ON *.* TO 'root'@'localhost' WITH GRANT OPTION ;
DROP DATABASE IF EXISTS test ;
EOSQL

  echo "${OS_DISTRO}: Writing 1st boot script: $MARIADB_DATABASE database: $MARIADB_USER"
  echo "CREATE DATABASE IF NOT EXISTS $MARIADB_DATABASE ;" >> "$TEMP_FILE"
  echo "CREATE USER '$MARIADB_USER'@'%' IDENTIFIED BY '$MARIADB_PASSWORD' ;" >> "$TEMP_FILE"
  echo "GRANT ALL ON $MARIADB_DATABASE.* TO '$MARIADB_USER'@'%' $MARIADB_X509  ;" >> "$TEMP_FILE"

  echo "${OS_DISTRO}: Writing 1st boot script: $DB_NAME database: $DB_USER"
  echo "CREATE DATABASE IF NOT EXISTS $DB_NAME ;" >> "$TEMP_FILE"
  echo "CREATE USER '$DB_USER'@'%' IDENTIFIED BY '$DB_PASSWORD' ;" >> "$TEMP_FILE"
  echo "GRANT ALL ON $DB_NAME.* TO '$DB_USER'@'%' $MARIADB_X509 ;" >> "$TEMP_FILE"

  if [ -z "$DB_NAME_1" -a -z "$DB_USER_1" -a -z "$DB_PASSWORD_1" ]; then
    echo "${OS_DISTRO}: Writing 1st boot script: $DB_NAME_1 database: $DB_USER_1"
    echo "CREATE DATABASE IF NOT EXISTS $DB_NAME_1 ;" >> "$TEMP_FILE"
    echo "CREATE USER '$DB_USER_1'@'%' IDENTIFIED BY '$DB_PASSWORD_1' ;" >> "$TEMP_FILE"
    echo "GRANT ALL ON $DB_NAME_1.* TO '$DB_USER_1'@'%' $MARIADB_X509 ;" >> "$TEMP_FILE"
  fi

  echo 'FLUSH PRIVILEGES ;' >> "$TEMP_FILE"
  MYSQLD_CMD="${MYSQLD_CMD} --init-file="$TEMP_FILE""

fi

echo "${OS_DISTRO}: Launching Container application"

chown -R mysql:mysql "$DATADIR"
exec ${MYSQLD_CMD}
