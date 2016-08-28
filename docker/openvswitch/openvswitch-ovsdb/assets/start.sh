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

OVN_DIR=/var/lib/ovn
OVN_LOG_DIR=/var/log/ovn
mkdir -p $OVN_DIR
mkdir -p $OVN_LOG_DIR

if [ ! -f  $OVN_DIR/conf.db ]; then
    echo "Creating DB"
    ovsdb-tool create $OVN_DIR/conf.db /usr/share/openvswitch/vswitch.ovsschema
fi

NODE_IP="$(ip -f inet -o addr show eth0|cut -d\  -f 7 | cut -d/ -f 1)"
exec ovsdb-server $OVN_DIR/conf.db \
      --remote=ptcp:6640:127.0.0.1 \
      --remote=ptcp:6640:${NODE_IP} \
      --remote=punix:/var/run/openvswitch/db.sock \
      --private-key=db:Open_vSwitch,SSL,private_key \
      --certificate=db:Open_vSwitch,SSL,certificate \
      --bootstrap-ca-cert=db:Open_vSwitch,SSL,ca_cert \
      --no-chdir \
      --log-file=$OVN_LOG_DIR/ovsdb-server.log \
      --pidfile=/var/run/ovsdb-server.pid \
      --verbose
