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
echo "${OS_DISTRO}: Email Config Starting"
################################################################################
. /etc/os-container.env
. /opt/harbor/service-hosts.sh
. /opt/harbor/harbor-common.sh
. /opt/harbor/portal/vars.sh


################################################################################
check_required_vars PORTAL_CONFIG_FILE \
                    OS_DOMAIN \
                    AUTH_PORTAL_SMTP_HOST \
                    AUTH_PORTAL_SMTP_PORT \
                    AUTH_PORTAL_SMTP_USER \
                    AUTH_PORTAL_SMTP_PASS \
                    AUTH_PORTAL_DEFAULT_FROM_EMAIL \
                    AUTH_PORTAL_DEFAULT_ADMIN_EMAIL


mkdir -p $(dirname ${PORTAL_CONFIG_FILE})
################################################################################
crudini --set ${PORTAL_CONFIG_FILE} Mailers smtp_server "${AUTH_PORTAL_SMTP_HOST}"
crudini --set ${PORTAL_CONFIG_FILE} Mailers smtp_port "${AUTH_PORTAL_SMTP_PORT}"
crudini --set ${PORTAL_CONFIG_FILE} Mailers smtp_security_type "STARTTLS"
crudini --set ${PORTAL_CONFIG_FILE} Mailers smtp_use_auth "True"
crudini --set ${PORTAL_CONFIG_FILE} Mailers smtp_username "${AUTH_PORTAL_SMTP_USER}"
crudini --set ${PORTAL_CONFIG_FILE} Mailers smtp_password "${AUTH_PORTAL_SMTP_PASS}"
crudini --set ${PORTAL_CONFIG_FILE} Mailers default_from_email "${AUTH_PORTAL_DEFAULT_FROM_EMAIL}"
crudini --set ${PORTAL_CONFIG_FILE} Mailers default_admin_email "${AUTH_PORTAL_DEFAULT_ADMIN_EMAIL}"
