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
echo "${OS_DISTRO}: Configuring horizon"
################################################################################
. /etc/os-container.env
. /opt/harbor/service-hosts.sh
. /opt/harbor/harbor-common.sh
. /opt/harbor/horizon/vars.sh


################################################################################
check_required_vars OS_DOMAIN \
                    API_APACHE_CONFIG_FILE \
                    API_TLS_KEY \
                    API_TLS_CERT \
                    API_TLS_CA \
                    HORIZON_API_SERVICE_HOST \
                    HORIZON_API_SERVICE_HOST_SVC \
                    HORIZON_API_SERVICE_PORT


################################################################################
sed -i "s|{{ OS_DOMAIN }}|${OS_DOMAIN}|g" ${API_APACHE_CONFIG_FILE}


################################################################################
sed -i "s|{{ API_TLS_KEY }}|${API_TLS_KEY}|g" ${API_APACHE_CONFIG_FILE}
sed -i "s|{{ API_TLS_CERT }}|${API_TLS_CERT}|g" ${API_APACHE_CONFIG_FILE}
sed -i "s|{{ API_TLS_CA }}|${API_TLS_CA}|g" ${API_APACHE_CONFIG_FILE}
sed -i "s|{{ HORIZON_API_SERVICE_HOST }}|${HORIZON_API_SERVICE_HOST}|g" ${API_APACHE_CONFIG_FILE}
sed -i "s|{{ HORIZON_API_SERVICE_HOST_SVC }}|${HORIZON_API_SERVICE_HOST_SVC}|g" ${API_APACHE_CONFIG_FILE}
sed -i "s|{{ HORIZON_API_SERVICE_PORT }}|${HORIZON_API_SERVICE_PORT}|g" ${API_APACHE_CONFIG_FILE}


# /opt/stack/horizon/manage.py make_web_conf \
# --apache \
# --ssl \
# --mail=webmaster@${OS_DOMAIN} \
# --project=openstack_dashboard \
# --hostname=${HORIZON_API_SERVICE_HOST} \
# --sslcert=${API_TLS_CERT} \
# --sslkey=${API_TLS_KEY} > ${API_APACHE_CONFIG_FILE}
