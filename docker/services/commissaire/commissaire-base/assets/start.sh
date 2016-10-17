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
exec tail -f /dev/null




cat mystorage.conf
{
  "storage-handlers": [{
      "name": "commissaire.storage.etcd",
      "server_url": "https://commissaire-etcd.os-commissaire.svc.build.harboros.net:2379",
      "certificate_path": "/run/harbor/auth/user/tls.crt",
      "certificate_key_path": "/run/harbor/auth/user/tls.key",
      "models": ["*"]
    }
  ]
}

commissaire-storage-service -c mystorage.conf --bus-uri redis://127.0.0.1:6379 &


cat config.conf
{
    "listen-interface": "127.0.0.1",
    "listen-port": 8000,
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
