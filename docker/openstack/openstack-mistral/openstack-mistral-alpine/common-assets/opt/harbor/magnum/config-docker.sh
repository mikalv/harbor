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
echo "${OS_DISTRO}: Configuring docker"
################################################################################
. /etc/os-container.env
. /opt/harbor/service-hosts.sh
. /opt/harbor/harbor-common.sh
. /opt/harbor/mistral/vars.sh


################################################################################
check_required_vars MISTRAL_CONFIG_FILE \
                    OS_DOMAIN \
                    MISTRAL_DB_CA \
                    MISTRAL_DB_KEY \
                    MISTRAL_DB_CERT


################################################################################
crudini --set ${MISTRAL_CONFIG_FILE} docker docker_remote_api_version "1.20"
crudini --set ${MISTRAL_CONFIG_FILE} docker default_timeout "60"
crudini --set ${MISTRAL_CONFIG_FILE} docker api_insecure "False"
crudini --set ${MISTRAL_CONFIG_FILE} docker ca_file "${MISTRAL_DB_CA}"
crudini --set ${MISTRAL_CONFIG_FILE} docker cert_file "${MISTRAL_DB_CERT}"
crudini --set ${MISTRAL_CONFIG_FILE} docker key_file "${MISTRAL_DB_KEY}"
