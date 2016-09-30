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
tail -f /dev/null
echo "${OS_DISTRO}: Launching"
################################################################################
. /etc/os-container.env || true
. /opt/harbor/service-hosts.sh
. /opt/harbor/harbor-common.sh
. /opt/harbor/cinder/vars.sh


echo "${OS_DISTRO}: Setting up ${DEVICE} for cinder with volume group ${CINDER_VOLUME_GROUP}"
################################################################################
check_required_vars CINDER_BACKEND_DEV \
                    CINDER_VOLUME_GROUP

if ! vgscan | grep -q "${CINDER_VOLUME_GROUP}"; then
  pvdisplay /dev/${CINDER_BACKEND_DEV} &> /dev/null || (
    pvcreate /dev/${CINDER_BACKEND_DEV}
  )
  vgcreate ${CINDER_VOLUME_GROUP} /dev/${CINDER_BACKEND_DEV}
fi

echo "${OS_DISTRO}: Prepped"
################################################################################
