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
: ${ETCD_PEERS_PORT:="7001"}
: ${ETCD_PORT:="4001"}
: ${ETCD_HOSTNAME_VAR:="ETCD_SERVICE_HOST_SVC"}
: ${ETCD_HOSTNAME:="${!ETCD_HOSTNAME_VAR}"}
: ${ETCD_PROXY_POD_TYPE:="normal"}
: ${ETCD_PROXY_POD_EXIT_FILE:="/pod/etcd/terminate-proxy"}



echo "${OS_DISTRO}: Container application launch"
################################################################################
check_required_vars OS_DOMAIN \
                    ETCD_HOSTNAME \
                    ETCD_PEERS_PORT \
                    ETCD_PORT \
                    ETCD_PROXY_POD_EXIT_FILE


echo "${OS_DISTRO}: Container application launch"
################################################################################
if [ "${ETCD_PROXY_POD_TYPE}" == "Job" ] ; then
  /job-control.sh &
  etcd \
  --proxy=on \
  --listen-client-urls="http://127.0.0.1:${ETCD_PORT}" \
  --initial-cluster="default=https://${ETCD_HOSTNAME}:${ETCD_PEERS_PORT}" \
  --client-cert-auth \
  --key-file /run/harbor/auth/user/tls.key \
  --cert-file /run/harbor/auth/user/tls.crt \
  --trusted-ca-file /run/harbor/auth/user/tls.ca \
  --peer-client-cert-auth \
  --peer-key-file /run/harbor/auth/user/tls.key \
  --peer-cert-file /run/harbor/auth/user/tls.crt \
  --peer-trusted-ca-file /run/harbor/auth/user/tls.ca || exit 0
else
  exec etcd \
        --proxy=on \
        --listen-client-urls="http://127.0.0.1:${ETCD_PORT}" \
        --initial-cluster="default=https://${ETCD_HOSTNAME}:${ETCD_PEERS_PORT}" \
        --client-cert-auth \
        --key-file /run/harbor/auth/user/tls.key \
        --cert-file /run/harbor/auth/user/tls.crt \
        --trusted-ca-file /run/harbor/auth/user/tls.ca \
        --peer-client-cert-auth \
        --peer-key-file /run/harbor/auth/user/tls.key \
        --peer-cert-file /run/harbor/auth/user/tls.crt \
        --peer-trusted-ca-file /run/harbor/auth/user/tls.ca
fi
