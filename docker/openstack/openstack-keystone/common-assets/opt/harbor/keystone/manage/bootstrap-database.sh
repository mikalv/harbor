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
echo "${OS_DISTRO}: Bootstrapping database"
################################################################################
. /etc/os-container.env
. /opt/harbor/service-hosts.sh
. /opt/harbor/harbor-common.sh
. /opt/harbor/keystone/vars.sh


################################################################################
check_required_vars KEYSTONE_CONFIG_FILE\
                    AUTH_KEYSTONE_ADMIN_USER \
                    AUTH_KEYSTONE_ADMIN_PASSWORD \
                    AUTH_KEYSTONE_ADMIN_PROJECT \
                    KEYSTONE_API_SERVICE_HOST_SVC \
                    KEYSTONE_API_SERVICE_HOST


################################################################################
su -s /bin/sh -c "keystone-manage --config-file=${KEYSTONE_CONFIG_FILE} db_sync" keystone


echo "${OS_DISTRO}: Database version"
################################################################################
su -s /bin/sh -c "keystone-manage --config-file=${KEYSTONE_CONFIG_FILE} db_version" keystone


echo "${OS_DISTRO}: Initializing database"
################################################################################
echo "${OS_DISTRO}: Cloud Admin (default domain) User: ${AUTH_KEYSTONE_ADMIN_USER}"
echo "${OS_DISTRO}: Admin URL:                         https://${KEYSTONE_API_SERVICE_HOST_SVC}:35357/v3"
echo "${OS_DISTRO}: Internal URL:                      https://${KEYSTONE_API_SERVICE_HOST_SVC}:5000/v3"
echo "${OS_DISTRO}: Public URL:                        https://${KEYSTONE_API_SERVICE_HOST}/v3"
su -s /bin/sh -c "keystone-manage --config-file=${KEYSTONE_CONFIG_FILE} bootstrap \
                  --bootstrap-username ${AUTH_KEYSTONE_ADMIN_USER} \
                  --bootstrap-password ${AUTH_KEYSTONE_ADMIN_PASSWORD} \
                  --bootstrap-project-name ${AUTH_KEYSTONE_ADMIN_PROJECT} \
                  --bootstrap-admin-url https://${KEYSTONE_API_SERVICE_HOST_SVC}:35357/v3 \
                  --bootstrap-public-url https://${KEYSTONE_API_SERVICE_HOST}/v3 \
                  --bootstrap-internal-url https://${KEYSTONE_API_SERVICE_HOST_SVC}:5000/v3 \
                  --bootstrap-region-id RegionOne" keystone
