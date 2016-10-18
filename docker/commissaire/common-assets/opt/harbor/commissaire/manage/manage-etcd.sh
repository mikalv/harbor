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
echo "${OS_DISTRO}: Managing ETCD"
################################################################################
. /etc/os-container.env
. /opt/harbor/service-hosts.sh
. /opt/harbor/harbor-common.sh
. /opt/harbor/commissaire/vars.sh


################################################################################
check_required_vars COMMISSAIRE_ETCD_SERVICE_HOST_SVC \
                    COMMISSAIRE_API_SERVICE_HOSTNAME \
                    COMMISSAIRE_SERVICE_NAMESPACE \
                    OS_DOMAIN \
                    COMMISSAIRE_DB_CA \
                    COMMISSAIRE_DB_KEY \
                    COMMISSAIRE_DB_CERT \
                    COMMISSAIRE_ETCD_SVC_PORT


################################################################################
function etcdctl_authed () {
etcdctl --endpoint https://${COMMISSAIRE_ETCD_SERVICE_HOST_SVC}:${COMMISSAIRE_ETCD_SVC_PORT} \
        --ca-file ${COMMISSAIRE_DB_CA} \
        --cert-file ${COMMISSAIRE_DB_CERT} \
        --key-file ${COMMISSAIRE_DB_KEY} "$@"
}


echo "${OS_DISTRO}: Testing Connection"
################################################################################
etcdctl_authed cluster-health


echo "${OS_DISTRO}: Managing Commissaire etcd dirs"
################################################################################
for x in clusters cluster hosts networks status; do
  etcd_path="/commissaire/"$x
  echo "++ Creating $etcd_path"
  etcdctl_authed mkdir $etcd_path || true
done


echo "${OS_DISTRO}: Managing Default Network Config"
################################################################################
DEFAULT_NETWORK_JSON=`python3 -c "from commissaire.constants import DEFAULT_CLUSTER_NETWORK_JSON; print(str(DEFAULT_CLUSTER_NETWORK_JSON).replace('\'', '\"'))"`
etcdctl_authed set /commissaire/networks/default "$DEFAULT_NETWORK_JSON"
