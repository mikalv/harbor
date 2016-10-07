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
echo "${OS_DISTRO}: Launching"
################################################################################
. /etc/os-container.env
. /opt/harbor/service-hosts.sh
. /opt/harbor/harbor-common.sh
. /opt/harbor/designate/vars.sh
export MARIADB_TEST_PORT="${DESIGNATE_DNS_MARIADB_SERVICE_PORT}"
export MARIADB_TEST_HOST="${DESIGNATE_DNS_MARIADB_SERVICE_HOST_SVC}"
PDNS_CONFIG_FILE=/etc/pdns/pdns.conf


################################################################################
check_required_vars OS_DOMAIN \
                    PDNS_CONFIG_FILE \
                    DESIGNATE_DNS_MARIADB_SERVICE_HOST_SVC \
                    DESIGNATE_DNS_MARIADB_SERVICE_PORT \
                    AUTH_DESIGNATE_PDNS_DB_USER \
                    AUTH_DESIGNATE_PDNS_DB_PASSWORD \
                    AUTH_DESIGNATE_PDNS_DB_NAME \
                    MY_IP


echo "${OS_DISTRO}: Testing service dependancies"
################################################################################
/usr/bin/mysql-insecure-test


echo "${OS_DISTRO}: Setting up pdns conf"
################################################################################
cat > ${PDNS_CONFIG_FILE} <<EOF
# General Config
setgid=pdns
setuid=pdns
config-dir=/etc/pdns
socket-dir=/var/run
guardian=yes
daemon=no
disable-axfr=no
local-address=${MY_IP}
local-port=553
master=no
slave=yes
cache-ttl=0
query-cache-ttl=0
negquery-cache-ttl=0
out-of-zone-additional-processing=no

# Launch gmysql backend
launch=gmysql

# gmysql parameters
gmysql-host=${DESIGNATE_DNS_MARIADB_SERVICE_HOST_SVC}
gmysql-port=${DESIGNATE_DNS_MARIADB_SERVICE_PORT}
gmysql-user=${AUTH_DESIGNATE_PDNS_DB_USER}
gmysql-password=${AUTH_DESIGNATE_PDNS_DB_PASSWORD}
gmysql-dbname=${AUTH_DESIGNATE_PDNS_DB_NAME}
gmysql-dnssec=yes
EOF


echo "${OS_DISTRO}: Moving pod configs into place"
################################################################################
cp -rfav $(dirname ${PDNS_CONFIG_FILE})/* /pod$(dirname ${PDNS_CONFIG_FILE})/
