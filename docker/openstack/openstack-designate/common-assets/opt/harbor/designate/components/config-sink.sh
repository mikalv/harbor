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
echo "${OS_DISTRO}: Configuring sink"
################################################################################
. /etc/os-container.env
. /opt/harbor/service-hosts.sh
. /opt/harbor/harbor-common.sh
. /opt/harbor/designate/vars.sh
PROC_CORES=$(grep -c ^processor /proc/cpuinfo)
: ${API_WORKERS:="$(( ( $PROC_CORES + 1 ) / 2))"}

################################################################################
check_required_vars DESIGNATE_CONFIG_FILE \
                    OS_DOMAIN \
                    DESIGNATE_API_SVC_PORT \
                    MY_IP \
                    API_WORKERS


echo "${OS_DISTRO}: Getting DESIGNATE_MANAGED_DNS_DOMAIN_ID"
################################################################################


tail -f /dev/null
#DESIGNATE_ADMIN_DOMAIN_ID="$(etcdctl --endpoint ${ETCDCTL_ENDPOINT} get /${OS_DISTRO}/${OPENSTACK_COMPONENT}/designate_admin_domain_id)"
DESIGNATE_MANAGED_DNS_DOMAIN_ID=$(etcdctl --endpoint ${ETCDCTL_ENDPOINT} get /${OS_DISTRO}/${OPENSTACK_COMPONENT}/designate_managed_dns_domain_id)
check_required_vars DESIGNATE_MANAGED_DNS_DOMAIN_ID


echo "${OS_DISTRO}: Getting DESIGNATE_INTERNAL_DNS_DOMAIN_ID"
################################################################################
#DESIGNATE_ADMIN_DOMAIN_ID="$(etcdctl --endpoint ${ETCDCTL_ENDPOINT} get /${OS_DISTRO}/${OPENSTACK_COMPONENT}/designate_admin_domain_id)"
DESIGNATE_INTERNAL_DNS_DOMAIN_ID=$(etcdctl --endpoint ${ETCDCTL_ENDPOINT} get /${OS_DISTRO}/${OPENSTACK_COMPONENT}/designate_internal_dns_domain_id)
check_required_vars DESIGNATE_INTERNAL_DNS_DOMAIN_ID


echo "${OS_DISTRO}: SINK CONFIG"
################################################################################
crudini --set $cfg service:sink enabled_notification_handlers "nova_fixed, neutron_floatingip"

crudini --set $cfg handler:neutron_floatingip zone_id "${DESIGNATE_MANAGED_DNS_DOMAIN_ID}"
crudini --set $cfg handler:neutron_floatingip domain_id "${DESIGNATE_MANAGED_DNS_DOMAIN_ID}"
crudini --set $cfg handler:neutron_floatingip notification_topics "notifications_dns"
crudini --set $cfg handler:neutron_floatingip control_exchange "neutron"
crudini --set $cfg handler:neutron_floatingip format "%(octet0)s-%(octet1)s-%(octet2)s-%(octet3)s.%(zone)s"


crudini --set $cfg handler:nova_fixed zone_id "${DESIGNATE_INTERNAL_DNS_DOMAIN_ID}"
crudini --set $cfg handler:nova_fixed domain_id "${DESIGNATE_INTERNAL_DNS_DOMAIN_ID}"
crudini --set $cfg handler:nova_fixed notification_topics "notifications_dns"
crudini --set $cfg handler:nova_fixed control_exchange "nova"
crudini --set $cfg handler:nova_fixed format '%(hostname)s.%(project)s.%(zone)s'
