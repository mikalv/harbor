#!/bin/sh
set -e
: ${CFG_SECTION:="database"}
echo "Configuring $cfg ${CFG_SECTION}"

set -x
: ${MARIADB_CA:="/etc/os-ssl-database/database-ca.crt"}
: ${MARIADB_KEY:="/etc/os-ssl-database/database.key"}
: ${MARIADB_CIRT:="/etc/os-ssl-database/database.crt"}
: ${MARIADB_CHARSET:="utf8"}
: ${MARIADB_TLS:="True"}
: ${DB_CA:="${MARIADB_CA}"}
: ${DB_KEY:="${MARIADB_KEY}"}
: ${DB_CIRT:="${MARIADB_CIRT}"}
: ${DB_USER:="${MARIADB_USER}"}
: ${DB_PASSWORD:="${MARIADB_PASSWORD}"}
: ${DB_HOST:="${MARIADB_SERVICE_HOST}"}
: ${DB_NAME:="${MARIADB_NAME}"}
: ${DB_CHARSET:="${MARIADBDB_CHARSET}"}
: ${DB_TLS:="${MARIADB_TLS}"}
: ${CFG_SECTION:="database"}

check_required_vars cfg DB_USER DB_PASSWORD DB_HOST DB_NAME DB_CHARSET \
                        DB_CA DB_KEY DB_CIRT DB_TLS \
                        CFG_SECTION

if [ "$DB_TLS" = "True" ]; then
  CONNECTION_STRING="mysql+pymysql://${DB_USER}:${DB_PASSWORD}@${DB_HOST}/${DB_NAME}?charset=${DB_CHARSET}&ssl_ca=${DB_CA}&ssl_key=${DB_KEY}&ssl_cert=${DB_CIRT}&ssl_verify_cert"
else
  CONNECTION_STRING="mysql+pymysql://${DB_USER}:${DB_PASSWORD}@${DB_HOST}/${DB_NAME}?charset=${DB_CHARSET}"
fi;

crudini --set $cfg ${CFG_SECTION} connection "${CONNECTION_STRING}"
