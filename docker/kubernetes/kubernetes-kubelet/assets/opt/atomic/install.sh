#!/bin/sh

# Copyright 2016 Port Direct
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -e
################################################################################
. /opt/harbor/service-hosts.sh
. /opt/harbor/harbor-common.sh
: ${HOST_FS_TEMPLATE:="/opt/atomic/rootfs"}

################################################################################
function recursive_sed {
  find ${HOST_FS_TEMPLATE} -type f -print0 | xargs -0 sed -i "$@"
}
function apply_params_sed {
  for VAR in $VAR_LIST; do
    check_required_vars $VAR
    recursive_sed "s|{{ ${VAR} }}|${!VAR}|g"
  done
}
function install_app {
  cp -rfav ${HOST_FS_TEMPLATE}/* ${HOST_FS}/
}


################################################################################
VAR_LIST="CONFDIR \
          DATADIR \
          IMAGE \
          NAME"

################################################################################
check_required_vars VAR_LIST \
                    ${VAR_LIST} \
                    HOST_FS_TEMPLATE \
                    HOST_FS


################################################################################
apply_params_sed
install_app
