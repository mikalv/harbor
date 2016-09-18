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
. /opt/harbor/heat/vars.sh


################################################################################
check_required_vars HEAT_CONFIG_FILE \
                    OS_DOMAIN \
                    HEAT_DB_CA \
                    KEYSTONE_API_SERVICE_HOST_SVC


################################################################################
crudini --set $HEAT_CONFIG_FILE clients endpoint_type "internalURL"
crudini --set $HEAT_CONFIG_FILE clients ca_file "${HEAT_DB_CA}"
crudini --set $HEAT_CONFIG_FILE clients insecure "False"


################################################################################
crudini --set $HEAT_CONFIG_FILE clients_keystone endpoint_type "internalURL"
crudini --set $HEAT_CONFIG_FILE clients_keystone auth_uri "https://${KEYSTONE_API_SERVICE_HOST_SVC}"
crudini --set $HEAT_CONFIG_FILE clients_keystone ca_file "${HEAT_DB_CA}"
crudini --set $HEAT_CONFIG_FILE clients_keystone insecure "False"


################################################################################
crudini --set $HEAT_CONFIG_FILE clients_neutron endpoint_type "adminURL"
crudini --set $HEAT_CONFIG_FILE clients_neutron ca_file "${HEAT_DB_CA}"
crudini --set $HEAT_CONFIG_FILE clients_neutron insecure "False"


################################################################################
crudini --set $HEAT_CONFIG_FILE clients_nova endpoint_type "internalURL"
crudini --set $HEAT_CONFIG_FILE clients_nova ca_file "${HEAT_DB_CA}"
crudini --set $HEAT_CONFIG_FILE clients_nova insecure "False"


################################################################################
crudini --set $HEAT_CONFIG_FILE clients_cinder endpoint_type "internalURL"
crudini --set $HEAT_CONFIG_FILE clients_cinder ca_file "${HEAT_DB_CA}"
crudini --set $HEAT_CONFIG_FILE clients_cinder insecure "False"


################################################################################
crudini --set $HEAT_CONFIG_FILE clients_glance endpoint_type "adminURL"
crudini --set $HEAT_CONFIG_FILE clients_glance ca_file "${HEAT_DB_CA}"
crudini --set $HEAT_CONFIG_FILE clients_glance insecure "False"


################################################################################
crudini --set $HEAT_CONFIG_FILE clients_heat endpoint_type "internalURL"
crudini --set $HEAT_CONFIG_FILE clients_heat ca_file "${HEAT_DB_CA}"
crudini --set $HEAT_CONFIG_FILE clients_heat insecure "False"


################################################################################
crudini --set $HEAT_CONFIG_FILE clients_magnum endpoint_type "internalURL"
crudini --set $HEAT_CONFIG_FILE clients_magnum ca_file "${HEAT_DB_CA}"
crudini --set $HEAT_CONFIG_FILE clients_magnum insecure "False"
