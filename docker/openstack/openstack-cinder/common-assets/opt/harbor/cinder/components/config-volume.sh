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
echo "${OS_DISTRO}: Configuring Cinder volume"
################################################################################
. /etc/os-container.env
. /opt/harbor/service-hosts.sh
. /opt/harbor/harbor-common.sh
. /opt/harbor/cinder/vars.sh


################################################################################
check_required_vars CINDER_CONFIG_FILE \
                    OS_DOMAIN \
                    CINDER_API_SVC_PORT \
                    CINDER_VOLUME_GROUP \
                    CINDER_BACKEND_ISCSI_NAME


crudini --set ${CINDER_CONFIG_FILE} DEFAULT default_volume_type "${CINDER_BACKEND_ISCSI_NAME}"
crudini --set ${CINDER_CONFIG_FILE} DEFAULT enabled_backends "${CINDER_BACKEND_ISCSI_NAME}"

crudini --set ${CINDER_CONFIG_FILE} ${CINDER_BACKEND_ISCSI_NAME} lvm_type "thin"
crudini --set ${CINDER_CONFIG_FILE} ${CINDER_BACKEND_ISCSI_NAME} lvm_max_over_subscription_ratio "1.5"
crudini --set ${CINDER_CONFIG_FILE} ${CINDER_BACKEND_ISCSI_NAME} iscsi_helper "tgtadm"
crudini --set ${CINDER_CONFIG_FILE} ${CINDER_BACKEND_ISCSI_NAME} volume_group "${CINDER_VOLUME_GROUP}"
crudini --set ${CINDER_CONFIG_FILE} ${CINDER_BACKEND_ISCSI_NAME} volume_driver "cinder.volume.drivers.lvm.LVMVolumeDriver"
crudini --set ${CINDER_CONFIG_FILE} ${CINDER_BACKEND_ISCSI_NAME} volume_backend_name "${CINDER_BACKEND_ISCSI_NAME}"
