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
mkdir -p /etc/commissaire
cat > /etc/commissaire/config.conf <<EOF
{
    "listen-interface": "127.0.0.1",
    "listen-port": 8001,
    "bus-uri": "redis://127.0.0.1:6379/",
    "authentication-plugin": {
        "name": "commissaire_http.authentication.httpbasicauth",
        "users": {
            "a": {
                "hash": "$2a$12$GlBCEIwz85QZUCkWYj11he6HaRHufzIvwQjlKeu7Rwmqi/mWOpRXK"
            }
        }
    }
}
EOF

cat /run/harbor/auth/ssl/tls.crt > /etc/commissaire/sever.pem
cat /run/harbor/auth/ssl/tls.key >> /etc/commissaire/sever.pem
