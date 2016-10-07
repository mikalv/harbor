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
echo "${OS_DISTRO}: Cinder Config Starting"
################################################################################
. /etc/os-container.env
. /opt/harbor/service-hosts.sh
. /opt/harbor/harbor-common.sh
. /opt/harbor/designate/vars.sh
. /opt/harbor/designate/manage/env-keystone-auth.sh


################################################################################
check_required_vars DESIGNATE_CONFIG_FILE \
                    OS_DOMAIN \
                    AUTH_DESIGNATE_KEYSTONE_REGION \
                    AUTH_DESIGNATE_KEYSTONE_DOMAIN \
                    AUTH_DESIGNATE_KEYSTONE_PROJECT_DOMAIN \
                    AUTH_DESIGNATE_KEYSTONE_PROJECT \
                    AUTH_DESIGNATE_KEYSTONE_PROJECT_USER_ROLE \
                    AUTH_DESIGNATE_KEYSTONE_USER \
                    AUTH_DESIGNATE_KEYSTONE_PASSWORD \
                    DESIGNATE_ADMIN_PROJECT \
                    DESIGNATE_ADMIN_DOMAIN \
                    DESIGNATE_DNS_SERVICE_HOST_SVC \
                    DESIGNATE_MDNS_SERVICE_HOST_SVC \
                    DESIGNATE_POOL_ID \
                    DESIGNATE_POOL_NAMESERVERS_ID \
                    DESIGNATE_POOL_TARGETS_ID \
                    AUTH_DESIGNATE_PDNS_DB_USER \
                    AUTH_DESIGNATE_PDNS_DB_PASSWORD \
                    DESIGNATE_DNS_MARIADB_SERVICE_HOST_SVC \
                    DESIGNATE_DNS_MARIADB_SERVICE_PORT \
                    AUTH_DESIGNATE_PDNS_DB_NAME


################################################################################
DESIGNATE_DNS_SERVICE_SVC_IP=172.16.0.1
DESIGNATE_MDNS_SERVICE_SVC_IP=172.16.0.1
check_required_vars DESIGNATE_DNS_SERVICE_SVC_IP DESIGNATE_MDNS_SERVICE_SVC_IP


################################################################################
DESIGNATE_DOMAIN_ID=$(openstack domain create --or-show --enable -f value -c id \
    --description="Service Domain for ${OS_DOMAIN}/${AUTH_DESIGNATE_KEYSTONE_REGION}" \
    "${DESIGNATE_ADMIN_DOMAIN}")
check_required_vars DESIGNATE_DOMAIN_ID


################################################################################
DESIGNATE_PROJECT_ID=$(openstack project create --or-show --enable -f value -c id \
    --domain="${DESIGNATE_DOMAIN_ID}" \
    --description="Service Project for ${OS_DOMAIN}/${AUTH_DESIGNATE_KEYSTONE_REGION}" \
    "${DESIGNATE_ADMIN_PROJECT}")
check_required_vars DESIGNATE_PROJECT_ID


################################################################################
crudini --set ${DESIGNATE_CONFIG_FILE} service:central managed_resource_tenant_id "${DESIGNATE_PROJECT_ID}"
crudini --set ${DESIGNATE_CONFIG_FILE} service:central managed_resource_email "hostmaster@${OS_DOMAIN}."
crudini --set ${DESIGNATE_CONFIG_FILE} service:central default_pool_id "${DESIGNATE_POOL_ID}"



################################################################################
crudini --set ${DESIGNATE_CONFIG_FILE} service:pool_manager pool_id "${DESIGNATE_POOL_ID}"
crudini --set ${DESIGNATE_CONFIG_FILE} pool:${DESIGNATE_POOL_ID} nameservers "${DESIGNATE_POOL_NAMESERVERS_ID}"
crudini --set ${DESIGNATE_CONFIG_FILE} pool:${DESIGNATE_POOL_ID} targets "${DESIGNATE_POOL_TARGETS_ID}"
crudini --set ${DESIGNATE_CONFIG_FILE} pool:${DESIGNATE_POOL_ID} also_notifies ""

crudini --set ${DESIGNATE_CONFIG_FILE} pool_nameserver:${DESIGNATE_POOL_NAMESERVERS_ID} port "553"
crudini --set ${DESIGNATE_CONFIG_FILE} pool_nameserver:${DESIGNATE_POOL_NAMESERVERS_ID} host "${DESIGNATE_DNS_SERVICE_SVC_IP}"


################################################################################
crudini --set ${DESIGNATE_CONFIG_FILE} pool_target:${DESIGNATE_POOL_TARGETS_ID} options "connection: mysql://${AUTH_DESIGNATE_PDNS_DB_USER}:${AUTH_DESIGNATE_PDNS_DB_PASSWORD}@${DESIGNATE_DNS_MARIADB_SERVICE_HOST_SVC}:${DESIGNATE_DNS_MARIADB_SERVICE_PORT}/${AUTH_DESIGNATE_PDNS_DB_NAME}?charset=utf8"
crudini --set ${DESIGNATE_CONFIG_FILE} pool_target:${DESIGNATE_POOL_TARGETS_ID} masters "${DESIGNATE_MDNS_SERVICE_SVC_IP}:5354"
crudini --set ${DESIGNATE_CONFIG_FILE} pool_target:${DESIGNATE_POOL_TARGETS_ID} "type" "powerdns"


################################################################################
cat > /etc/designate/pools.yaml <<EOF
- name: default
  description: Harbor PowerDNS Pool
  attributes: {}

  ns_records:
    - hostname: ns1.${OS_DOMAIN}.
      priority: 1

  nameservers:
    - host: ${DESIGNATE_DNS_SERVICE_SVC_IP}
      port: 553

  targets:
    - type: powerdns
      description: PowerDNS Database Cluster

      masters:
        - host: ${DESIGNATE_MDNS_SERVICE_SVC_IP}
          port: 5354

      options:
        host: ${DESIGNATE_DNS_SERVICE_SVC_IP}
        port: 553
        connection: mysql://${AUTH_DESIGNATE_PDNS_DB_USER}:${AUTH_DESIGNATE_PDNS_DB_PASSWORD}@${MARIADB_SERVICE_HOST}/${AUTH_DESIGNATE_PDNS_DB_NAME}?charset=utf8
EOF
chown designate:designate /etc/designate/pools.yaml
