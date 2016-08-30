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
echo "${OS_DISTRO}: Launching OVS DB Container"
################################################################################
. /etc/os-container.env
. /opt/harbor/service-hosts.sh
. /opt/harbor/harbor-common.sh


################################################################################
check_required_vars OS_DOMAIN \
                    MY_IP


################################################################################
if [ ! -f  $OVN_DIR/conf.db ]; then
    echo "Creating DB"
    ovsdb-tool create /var/run/openvswitch/conf.db /usr/share/openvswitch/vswitch.ovsschema
fi


echo "${OS_DISTRO}: Launching Container Application"
################################################################################
echo "${OS_DISTRO}: Serving remote connections on: ptcp:6640:${MY_IP}"
exec ovsdb-server /var/run/openvswitch/conf.db \
      --log-file="/dev/null" \
      --remote="ptcp:6640:127.0.0.1" \
      --remote="ptcp:6640:${MY_IP}" \
      --remote="punix:/var/run/openvswitch/db.sock" \
      --private-key="db:Open_vSwitch,SSL,private_key" \
      --certificate="db:Open_vSwitch,SSL,certificate" \
      --bootstrap-ca-cert="db:Open_vSwitch,SSL,ca_cert" \
      --no-chdir
