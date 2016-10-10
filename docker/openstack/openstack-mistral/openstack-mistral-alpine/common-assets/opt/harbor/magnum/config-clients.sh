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
echo "${OS_DISTRO}: Configuring clients"
################################################################################
. /etc/os-container.env
. /opt/harbor/service-hosts.sh
. /opt/harbor/harbor-common.sh
. /opt/harbor/mistral/vars.sh


################################################################################
check_required_vars MISTRAL_CONFIG_FILE \
                    OS_DOMAIN \
                    MISTRAL_DB_CA \
                    KEYSTONE_API_SERVICE_HOST_SVC \
                    AUTH_MISTRAL_KEYSTONE_CLIENTS_REGION


################################################################################
crudini --set ${MISTRAL_CONFIG_FILE} barbican_client endpoint_type "internalURL"
crudini --set ${MISTRAL_CONFIG_FILE} barbican_client region_name "${AUTH_MISTRAL_KEYSTONE_CLIENTS_REGION}"


################################################################################
crudini --set ${MISTRAL_CONFIG_FILE} cinder_client region_name "${AUTH_MISTRAL_KEYSTONE_CLIENTS_REGION}"


################################################################################
crudini --set ${MISTRAL_CONFIG_FILE} glance_client region_name "${AUTH_MISTRAL_KEYSTONE_CLIENTS_REGION}"
crudini --set ${MISTRAL_CONFIG_FILE} glance_client endpoint_type "internalURL"
crudini --set ${MISTRAL_CONFIG_FILE} glance_client api_version "2"
crudini --set ${MISTRAL_CONFIG_FILE} glance_client ca_file "${MISTRAL_DB_CA}"
crudini --set ${MISTRAL_CONFIG_FILE} glance_client insecure "False"


################################################################################
crudini --set ${MISTRAL_CONFIG_FILE} heat_client region_name "${AUTH_MISTRAL_KEYSTONE_CLIENTS_REGION}"
crudini --set ${MISTRAL_CONFIG_FILE} heat_client endpoint_type "internalURL"
crudini --set ${MISTRAL_CONFIG_FILE} heat_client api_version "1"
crudini --set ${MISTRAL_CONFIG_FILE} heat_client ca_file "${MISTRAL_DB_CA}"
crudini --set ${MISTRAL_CONFIG_FILE} heat_client insecure "False"


################################################################################
crudini --set ${MISTRAL_CONFIG_FILE} mistral_client endpoint_type "internalURL"
crudini --set ${MISTRAL_CONFIG_FILE} mistral_client region_name "${AUTH_MISTRAL_KEYSTONE_CLIENTS_REGION}"


################################################################################
crudini --set ${MISTRAL_CONFIG_FILE} neutron_client region_name "${AUTH_MISTRAL_KEYSTONE_CLIENTS_REGION}"
crudini --set ${MISTRAL_CONFIG_FILE} neutron_client endpoint_type "internalURL"
crudini --set ${MISTRAL_CONFIG_FILE} neutron_client ca_file "${MISTRAL_DB_CA}"
crudini --set ${MISTRAL_CONFIG_FILE} neutron_client insecure "False"


################################################################################
crudini --set ${MISTRAL_CONFIG_FILE} neutron_client region_name "${AUTH_MISTRAL_KEYSTONE_CLIENTS_REGION}"
crudini --set ${MISTRAL_CONFIG_FILE} neutron_client endpoint_type "internalURL"
crudini --set ${MISTRAL_CONFIG_FILE} neutron_client ca_file "${MISTRAL_DB_CA}"
crudini --set ${MISTRAL_CONFIG_FILE} neutron_client insecure "False"


################################################################################
crudini --set ${MISTRAL_CONFIG_FILE} nova_client region_name "${AUTH_MISTRAL_KEYSTONE_CLIENTS_REGION}"
crudini --set ${MISTRAL_CONFIG_FILE} nova_client endpoint_type "internalURL"
crudini --set ${MISTRAL_CONFIG_FILE} nova_client api_version "2"
crudini --set ${MISTRAL_CONFIG_FILE} nova_client ca_file "${MISTRAL_DB_CA}"
crudini --set ${MISTRAL_CONFIG_FILE} nova_client insecure "False"
