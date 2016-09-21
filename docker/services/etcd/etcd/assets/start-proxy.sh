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

tail -f /dev/null
echo "${OS_DISTRO}: Container application launch"
################################################################################
check_required_vars OS_DOMAIN \
                    POD_IP \
                    ETCD_SERVICE_HOST_SVC


echo "${OS_DISTRO}: Container application launch"
################################################################################
exec etcd \
      --proxy=on \
      --listen-client-urls="http://127.0.0.1:4001" \
      --initial-cluster="default=https://${ETCD_SERVICE_HOST_SVC}:7001" \
      --client-cert-auth \
      --key-file /run/harbor/auth/user/tls.key \
      --cert-file /run/harbor/auth/user/tls.crt \
      --trusted-ca-file /run/harbor/auth/user/tls.ca \
      --peer-client-cert-auth \
      --peer-key-file /run/harbor/auth/user/tls.key \
      --peer-cert-file /run/harbor/auth/user/tls.crt \
      --peer-trusted-ca-file /run/harbor/auth/user/tls.ca



etcdctl --debug --no-sync  --endpoints "https://${ETCD_SERVICE_HOST_SVC}:4001" --ca-file=/run/harbor/auth/user/tls.ca --cert-file=/run/harbor/auth/user/tls.crt --key-file=/run/harbor/auth/user/tls.key ls
         --cert-file value                identify HTTPS client using this SSL certificate file
         --key-file value                 identify HTTPS client using this SSL key file
         --ca-file value                  verify certificates of HTTPS-enabled servers using this CA bundle
         --username value, -u value       provide username[:password] and prompt if password is not supplied.
         --timeout value                  connection timeout per request (default: 1s)
         --total-timeout value            timeout for the command execution (except watch) (default: 5s)
         --help, -h                       show help
         --version, -v
