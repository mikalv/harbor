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
set -x
exec tail -f /dev/null

cat /run/harbor/auth/user/tls.ca >> /usr/lib/python3.5/site-packages/requests/cacert.pem
cat > ~/.commissaire.json <<EOF
{
    "username": "a",
    "password": "a",
    "endpoint": "https://commissaire.os-commissaire.svc.build.harboros.net:8001"
}
EOF

commctl cluster list



curl -k https://commissaire-etcd.os-commissaire.svc.build.harboros.net:2379/v2/keys \
 -v --key /run/harbor/auth/user/tls.key \
 --cacert /run/harbor/auth/user/tls.ca \
 --cert /run/harbor/auth/user/tls.crt


"server_url": "",
"certificate_ca_path": "${COMMISSAIRE_DB_CA}",
"certificate_path": "${COMMISSAIRE_DB_CERT}",
"certificate_key_path": "${COMMISSAIRE_DB_KEY}"
