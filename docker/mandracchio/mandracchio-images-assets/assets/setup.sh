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

rm -rf /srv/repo
docker cp mandracchio-build-repo:/srv/repo /srv/

rm -rf /srv/mandracchio
cp -rf /opt/mandracchio /srv/

iptables -I INPUT -s 192.168.122.0/24 -j ACCEPT
