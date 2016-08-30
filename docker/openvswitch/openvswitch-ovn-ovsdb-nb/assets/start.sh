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
echo "${OS_DISTRO}: Launching OVN Northbound DB Container"
################################################################################
. /etc/os-container.env
. /opt/harbor/service-hosts.sh
. /opt/harbor/harbor-common.sh
OVN_NB_IP=${MY_IP}


################################################################################
check_required_vars OVN_DIR \
                    OS_DOMAIN \
                    OVN_NB_IP


################################################################################
if [ ! -f ${OVN_DIR}/ovnnb.db ]; then
    echo "Creating DB"
    ovsdb-tool create $OVN_DIR/ovnnb.db /usr/share/openvswitch/ovn-nb.ovsschema
fi


echo "${OS_DISTRO}: Launching Container Application"
################################################################################
echo "${OS_DISTRO}: Serving remote connections on: ptcp:6642:${OVN_NB_IP}"
exec ovsdb-server  \
      --log-file="/dev/null" \
      --remote=punix:/var/run/openvswitch/ovnnb_db.sock \
      --remote=ptcp:6641:${OVN_NB_IP} \
      --unixctl=ovnnb_db.ctl ${OVN_DIR}/ovnnb.db
