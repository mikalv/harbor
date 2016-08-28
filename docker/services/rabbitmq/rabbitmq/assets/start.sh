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

###############################################################################
echo "${OS_DISTRO}: ${HARBOR_COMPONENT}: Adapting vars from base image"
################################################################################
RABBITMQ_USER="guest"
RABBITMQ_PASS="guest"
: ${RABBITMQ_NODENAME:="messaging"}
: ${RABBITMQ_LOG_BASE:=/var/log/rabbitmq}

################################################################################
echo "${OS_DISTRO}: ${HARBOR_COMPONENT}: Configuring"
################################################################################
sed -i '
  s|@RABBITMQ_USER@|'"$RABBITMQ_USER"'|g
  s|@RABBITMQ_PASS@|'"$RABBITMQ_PASS"'|g
' /etc/rabbitmq/rabbitmq.config

sed -i '
  s|@RABBITMQ_NODENAME@|'"$RABBITMQ_NODENAME"'|g
  s|@RABBITMQ_LOG_BASE@|'"$RABBITMQ_LOG_BASE"'|g
' /etc/rabbitmq/rabbitmq-env.conf

echo "127.0.0.1 $(hostname)" >> /etc/hosts


chown -R rabbitmq:rabbitmq /var/lib/rabbitmq
mkdir -p /var/log/rabbitmq
chown -R rabbitmq:rabbitmq /var/log/rabbitmq
################################################################################
echo "${OS_DISTRO}: ${HARBOR_COMPONENT}: Launching"
################################################################################
exec su -s /bin/sh -c "exec rabbitmq-server" rabbitmq
