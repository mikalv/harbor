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
echo "${OS_DISTRO}: Launching OVN Southbound DB Container"
################################################################################
. /etc/os-container.env
. /opt/harbor/service-hosts.sh
. /opt/harbor/harbor-common.sh
OVN_SB_IP=${MY_IP}


################################################################################
check_required_vars OVN_DIR \
                    OS_DOMAIN \
                    OVN_SB_IP


################################################################################
if [ ! -f ${OVN_DIR}/ovnsb.db ]; then
    echo "Creating DB"
    ovsdb-tool create $OVN_DIR/ovnsb.db /usr/share/openvswitch/ovn-sb.ovsschema
fi


echo "${OS_DISTRO}: Launching Container Application"
################################################################################
echo "${OS_DISTRO}: Serving remote connections on: ptcp:6642:${OVN_SB_IP}"
exec ovsdb-server  \
      --log-file="/dev/null" \
      --remote=punix:/var/run/openvswitch/ovnsb_db.sock \
      --remote=ptcp:6642:${OVN_SB_IP} \
      --unixctl=ovnsb_db.ctl ${OVN_DIR}/ovnsb.db
