#!/bin/sh

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
echo "${OS_DISTRO}: Starting Harbor kubernetes service update"
################################################################################
if [ "$UNDERCLOUD" = "True" ]; then
  echo "${OS_DISTRO}: Launching Kube2Sky for $OS_DISTRO undercloud"
  exec /kube2sky "$@"
else
  echo "$OS_DISTRO: Waiting"
  sleep 2s
  echo "$OS_DISTRO: Editing Hosts File"
  echo "$KUBERNETES_PORT_443_TCP_ADDR kubernetes.$OS_DOMAIN kubernetes" >> /etc/hosts
  sleep 1s
  echo "$OS_DISTRO: Launching Kube2Sky"
  exec /kube2sky \
    -domain=$OS_DOMAIN \
    -kube_master_url=https://kubernetes.$OS_DOMAIN \
    -kubecfg_file=/etc/harbor/auth/kubelet/kubeconfig.yaml
fi;
