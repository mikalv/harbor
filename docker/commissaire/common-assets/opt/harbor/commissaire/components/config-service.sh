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
echo "${OS_DISTRO}: Configuring Commissaire API"
################################################################################
. /etc/os-container.env
. /opt/harbor/service-hosts.sh
. /opt/harbor/harbor-common.sh
. /opt/harbor/commissaire/vars.sh


################################################################################
check_required_vars COMMISSAIRE_STOARGE_CONFIG_FILE \
                    COMMISSAIRE_ETCD_SERVICE_HOST_SVC \
                    COMMISSAIRE_API_SERVICE_HOSTNAME \
                    COMMISSAIRE_SERVICE_NAMESPACE \
                    OS_DOMAIN \
                    COMMISSAIRE_DB_CA \
                    COMMISSAIRE_DB_KEY \
                    COMMISSAIRE_DB_CERT \
                    COMMISSAIRE_ETCD_SVC_PORT \
                    ETCD_LOCAL_PORT


################################################################################
cat > ${COMMISSAIRE_STOARGE_CONFIG_FILE} <<EOF
{
  "storage-handlers": [{
      "name": "commissaire.storage.etcd",
      "server_url": "https://127.0.0.1:${ETCD_LOCAL_PORT}",
      "models": ["*"]
    }
  ]
}
EOF
