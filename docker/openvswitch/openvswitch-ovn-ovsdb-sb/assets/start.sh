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

if [ ! -f  $OVN_DIR/ovnnb.db ]; then
    echo "Creating DB"
    ovsdb-tool create $OVN_DIR/ovnsb.db /usr/share/openvswitch/ovn-sb.ovsschema
fi


exec ovsdb-server  \
      --log-file=${OVN_LOG_DIR}/ovsdb-server-sb.log \
      --remote=punix:/var/run/openvswitch/ovnsb_db.sock \
      --remote=ptcp:6642:0.0.0.0 \
      --pidfile=/var/run/openvswitch/ovnsb_db.pid \
      --unixctl=ovnsb_db.ctl ${OVN_DIR}/ovnsb.db --verbose
