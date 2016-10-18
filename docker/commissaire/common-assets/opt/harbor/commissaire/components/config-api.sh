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
check_required_vars COMMISSAIRE_CONFIG_FILE \
                    OS_DOMAIN \
                    COMMISSAIRE_API_SVC_PORT \
                    MY_IP \
                    COMMISSAIRE_API_PEM_FILE \
                    COMMISSAIRE_API_TLS_KEY \
                    COMMISSAIRE_API_TLS_CERT


################################################################################
cat ${COMMISSAIRE_API_TLS_CERT} > ${COMMISSAIRE_API_PEM_FILE}
cat ${COMMISSAIRE_API_TLS_KEY} >> ${COMMISSAIRE_API_PEM_FILE}


################################################################################
cat > ${COMMISSAIRE_CONFIG_FILE} <<EOF
{
    "listen-interface": "${MY_IP}",
    "listen-port": ${COMMISSAIRE_API_SVC_PORT},
    "bus-uri": "redis://127.0.0.1:6379/",
    "authentication-plugin": {
        "name": "commissaire_http.authentication.httpbasicauth",
        "users": {
            "a": {
                "hash": "\$2a\$12\$GlBCEIwz85QZUCkWYj11he6HaRHufzIvwQjlKeu7Rwmqi/mWOpRXK"
            }
        }
    }
}
EOF
