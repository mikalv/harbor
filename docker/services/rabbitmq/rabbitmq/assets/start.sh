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
: ${RABBITMQ_NODENAME:="messaging"}
: ${RABBITMQ_LOG_BASE:="/var/log/rabbitmq"}


################################################################################
check_required_vars OS_DOMAIN \
                    AUTH_MESSAGING_USER \
                    AUTH_MESSAGING_PASS \
                    RABBITMQ_NODENAME \
                    RABBITMQ_LOG_BASE


################################################################################
sed -i '
  s|@RABBITMQ_USER@|'"$AUTH_MESSAGING_USER"'|g
  s|@RABBITMQ_PASS@|'"$AUTH_MESSAGING_PASS"'|g
' /etc/rabbitmq/rabbitmq.config

sed -i '
  s|@RABBITMQ_NODENAME@|'"$RABBITMQ_NODENAME"'|g
  s|@RABBITMQ_LOG_BASE@|'"$RABBITMQ_LOG_BASE"'|g
' /etc/rabbitmq/rabbitmq-env.conf


################################################################################
echo "127.0.0.1 $(hostname)" >> /etc/hosts
echo "127.0.0.1 ${RABBITMQ_NODENAME}" >> /etc/hosts


################################################################################
mkdir -p /var/lib/rabbitmq
chown -R rabbitmq:rabbitmq /var/lib/rabbitmq
mkdir -p ${RABBITMQ_LOG_BASE}
chown -R rabbitmq:rabbitmq ${RABBITMQ_LOG_BASE}


echo "${OS_DISTRO}: Starting Container Application"
################################################################################
exec su -s /bin/sh -c "exec rabbitmq-server" rabbitmq
