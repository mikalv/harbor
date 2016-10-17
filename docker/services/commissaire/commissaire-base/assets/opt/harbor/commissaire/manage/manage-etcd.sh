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
function etcdctl_authed () {
etcdctl --endpoint https://commissaire-etcd.os-commissaire.svc.build.harboros.net:2379 \
        --ca-file /run/harbor/auth/user/tls.ca \
        --cert-file /run/harbor/auth/user/tls.crt \
        --key-file /run/harbor/auth/user/tls.key "$@"
}

etcdctl_authed cluster-health

echo "+ Creating Commissaire keyspaces..."
for x in clusters cluster hosts networks status; do
  etcd_path="/commissaire/"$x
  echo "++ Creating $etcd_path"
  etcdctl_authed mkdir $etcd_path || true
done

echo "+ Creating default network configuration..."
DEFAULT_NETWORK_JSON=`python -c "from commissaire.constants import DEFAULT_CLUSTER_NETWORK_JSON; print(str(DEFAULT_CLUSTER_NETWORK_JSON).replace('\'', '\"'))"`
etcdctl_authed set /commissaire/networks/default "$DEFAULT_NETWORK_JSON"


echo "+ Commissaire etcd namespace now looks like the following:"
etcdctl_authed ls --recursive /commissaire/
