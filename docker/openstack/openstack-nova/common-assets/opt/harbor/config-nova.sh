#!/bin/bash

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
echo "${OS_DISTRO}: Nova Config Common Config Starting"
################################################################################
. /etc/os-container.env
. /opt/harbor/service-hosts.sh
. /opt/harbor/harbor-common.sh
. /opt/harbor/nova/vars.sh


################################################################################
check_required_vars NOVA_CONFIG_FILE \
                    OS_DOMAIN \
                    MY_IP


################################################################################
mkdir -p /etc/nova


echo "${OS_DISTRO}: This container will use ${MY_IP} as its primary ip"
################################################################################
crudini --set ${NOVA_CONFIG_FILE} DEFAULT my_ip "${MY_IP}"


echo "${OS_DISTRO}: Starting logging config"
################################################################################
/opt/harbor/nova/config-logging.sh


echo "${OS_DISTRO}: Starting messaging config"
################################################################################
/opt/harbor/nova/config-messaging.sh


echo "${OS_DISTRO}: Starting keystone config"
################################################################################
/opt/harbor/nova/config-keystone.sh


echo "${OS_DISTRO}: Starting locks and concurrency config"
################################################################################
/opt/harbor/nova/config-concurrency.sh


echo "${OS_DISTRO}: Starting rootwrap config"
################################################################################
/opt/harbor/nova/config-rootwrap.sh


echo "${OS_DISTRO}: Starting scheduler config"
################################################################################
/opt/harbor/nova/config-scheduler.sh


echo "${OS_DISTRO}: Starting neutron config"
################################################################################
/opt/harbor/nova/config-neutron.sh


echo "${OS_DISTRO}: Starting cinder config"
################################################################################
/opt/harbor/nova/config-cinder.sh


echo "${OS_DISTRO}: Starting cinder config"
################################################################################
/opt/harbor/nova/config-glance.sh


echo "${OS_DISTRO}: Starting compute config"
################################################################################
/opt/harbor/nova/config-compute.sh
