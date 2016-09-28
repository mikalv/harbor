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

set -eo pipefail
echo "${OS_DISTRO}: Starting kubernetes ingress controller container"
################################################################################
RESPONSE=$(curl --fail --silent --max-time 1 127.0.0.1:8080/healthz/ping)
if [ "$RESPONSE" = "ok" ]; then
  echo "${OS_DISTRO}: We have localhost access to the api, disabling in-cluster config"
  export KUBERNETES_SERVICE_HOST=""
  export KUBERNETES_SERVICE_PORT=""
fi;

echo "${OS_DISTRO}: Launching kubernetes ingress controller"
################################################################################
exec /nginx-ingress-controller --v=3 --default-backend-service=os-loadbalancer/error-page-server --nginx-configmap="os-loadbalancer/${NGINX_CONFIGMAP}"
