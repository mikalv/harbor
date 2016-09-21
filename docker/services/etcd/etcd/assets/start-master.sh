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
echo "${OS_DISTRO}: Container starting"
################################################################################
. /usr/sbin/container-gen-env
. /etc/os-container.env
. /opt/harbor/harbor-vars.sh
. /opt/harbor/service-hosts.sh
. /opt/harbor/harbor-common.sh


echo "${OS_DISTRO}: Container application launch"
################################################################################
check_required_vars OS_DOMAIN \
                    POD_IP \
                    ETCD_SERVICE_HOST_SVC


echo "${OS_DISTRO}: Container application launch"
################################################################################
echo "$POD_IP $ETCD_SERVICE_HOST_SVC" >> /etc/hosts
exec etcd \
      --name=default \
      --listen-peer-urls="https://${ETCD_SERVICE_HOST_SVC}:7001" \
      --initial-advertise-peer-urls="https://${ETCD_SERVICE_HOST_SVC}:7001" \
      --initial-cluster="default=https://${ETCD_SERVICE_HOST_SVC}:7001" \
      --listen-client-urls="https://${ETCD_SERVICE_HOST_SVC}:4001" \
      --advertise-client-urls="https://${ETCD_SERVICE_HOST_SVC}:4001" \
      --initial-cluster-token="os-etcd" \
      --data-dir=/data \
      --client-cert-auth \
      --key-file /run/harbor/auth/ssl/tls.key \
      --cert-file /run/harbor/auth/ssl/tls.crt \
      --trusted-ca-file /run/harbor/auth/ssl/tls.ca \
      --peer-client-cert-auth \
      --peer-key-file /run/harbor/auth/ssl/tls.key \
      --peer-cert-file /run/harbor/auth/ssl/tls.crt \
      --peer-trusted-ca-file /run/harbor/auth/ssl/tls.ca
