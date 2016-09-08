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
echo "${OS_DISTRO}: Starting Rabbitmq Container"
################################################################################
source /etc/os-container.env
source /opt/harbor/harbor-vars.sh
source /opt/harbor/service-hosts.sh
source /opt/harbor/harbor-common.sh
: ${RABBIT_NODENAME:="messaging"}
: ${RABBIT_LOG_BASE:="/var/log/rabbitmq"}
: ${RABBIT_PORT:="5672"}
: ${RABBIT_DIST_PORT:="$(($RABBIT_PORT + 20000))"}


################################################################################
check_required_vars OS_DOMAIN \
                    RABBIT_PORT \
                    RABBIT_USER \
                    RABBIT_PASS \
                    RABBIT_NODENAME \
                    MY_IP


echo "${OS_DISTRO}: Translating env vars"
################################################################################
RABBIT_USER_VAL=${!RABBIT_USER}
RABBIT_PASS_VAL=${!RABBIT_PASS}

check_required_vars OS_DOMAIN \
                    RABBIT_USER_VAL \
                    RABBIT_PASS_VAL


echo "${OS_DISTRO}: This container will run on:"
################################################################################
echo "${OS_DISTRO}:    Node name:        ${RABBIT_NODENAME}"
echo "${OS_DISTRO}:    Node ip:          ${MY_IP}"
echo "${OS_DISTRO}:    Client port:      ${RABBIT_PORT}"
echo "${OS_DISTRO}:    Dist Port:        ${RABBIT_DIST_PORT}"


echo "${OS_DISTRO}: Writing config files"
################################################################################
sed -i '
  s|@RABBIT_USER@|'"$RABBIT_USER_VAL"'|g
  s|@RABBIT_PASS@|'"$RABBIT_PASS_VAL"'|g
  s|@RABBIT_PORT@|'"$RABBIT_PORT"'|g
' /etc/rabbitmq/rabbitmq.config

sed -i '
  s|@RABBIT_NODENAME@|'"$RABBIT_NODENAME"'|g
  s|@RABBIT_LOG_BASE@|'"$RABBIT_LOG_BASE"'|g
  s|@RABBIT_PORT@|'"$RABBIT_PORT"'|g
  s|@RABBIT_DIST_PORT@|'"$RABBIT_DIST_PORT"'|g
  s|@RABBIT_NODE_IP_ADDRESS@|'"$MY_IP"'|g
' /etc/rabbitmq/rabbitmq-env.conf


echo "${OS_DISTRO}: Setting up hosts file"
################################################################################
echo "127.0.0.1 $(hostname)" >> /etc/hosts
echo "127.0.0.1 ${RABBIT_NODENAME}" >> /etc/hosts


echo "${OS_DISTRO}: Ensuring correct permissions"
################################################################################
mkdir -p /var/lib/rabbitmq
chown -R rabbitmq:rabbitmq /var/lib/rabbitmq
mkdir -p ${RABBIT_LOG_BASE}
chown -R rabbitmq:rabbitmq ${RABBIT_LOG_BASE}


echo "${OS_DISTRO}: Starting Container Application"
################################################################################
exec su -s /bin/sh -c "exec rabbitmq-server" rabbitmq
