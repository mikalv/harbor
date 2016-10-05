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
echo "${OS_DISTRO}: Configuring messaging"
################################################################################
. /etc/os-container.env
. /opt/harbor/service-hosts.sh
. /opt/harbor/harbor-common.sh
. /opt/harbor/designate/vars.sh


################################################################################
check_required_vars DESIGNATE_CONFIG_FILE \
                    OS_DOMAIN \
                    AUTH_MESSAGING_PASS \
                    AUTH_MESSAGING_USER \
                    RABBITMQ_SERVICE_HOST_SVC \
                    DESIGNATE_DB_KEY \
                    DESIGNATE_DB_CERT \
                    DESIGNATE_DB_CA


echo "${OS_DISTRO}: RPC Backend"
################################################################################
crudini --set ${DESIGNATE_CONFIG_FILE} DEFAULT rpc_backend "rabbit"


echo "${OS_DISTRO}: Connection"
################################################################################
crudini --set ${DESIGNATE_CONFIG_FILE} oslo_messaging_rabbit rabbit_use_ssl "True"

crudini --set ${DESIGNATE_CONFIG_FILE} oslo_messaging_rabbit rabbit_host "${RABBITMQ_SERVICE_HOST_SVC}"
crudini --set ${DESIGNATE_CONFIG_FILE} oslo_messaging_rabbit rabbit_port "5672"
crudini --set ${DESIGNATE_CONFIG_FILE} oslo_messaging_rabbit rabbit_hosts "${RABBITMQ_SERVICE_HOST_SVC}:5672"

crudini --set ${DESIGNATE_CONFIG_FILE} oslo_messaging_rabbit rabbit_userid "${AUTH_MESSAGING_USER}"
crudini --set ${DESIGNATE_CONFIG_FILE} oslo_messaging_rabbit rabbit_password "${AUTH_MESSAGING_PASS}"


echo "${OS_DISTRO}: TLS"
################################################################################
crudini --set ${DESIGNATE_CONFIG_FILE} oslo_messaging_rabbit kombu_ssl_version "TLSv1_2"
crudini --set ${DESIGNATE_CONFIG_FILE} oslo_messaging_rabbit kombu_ssl_keyfile "${DESIGNATE_DB_KEY}"
crudini --set ${DESIGNATE_CONFIG_FILE} oslo_messaging_rabbit kombu_ssl_certfile "${DESIGNATE_DB_CERT}"
crudini --set ${DESIGNATE_CONFIG_FILE} oslo_messaging_rabbit kombu_ssl_ca_certs "${DESIGNATE_DB_CA}"


echo "${OS_DISTRO}: Config"
################################################################################
crudini --set ${DESIGNATE_CONFIG_FILE} oslo_messaging_rabbit rabbit_virtual_host "/"
crudini --set ${DESIGNATE_CONFIG_FILE} oslo_messaging_rabbit rabbit_ha_queues "False"
crudini --set ${DESIGNATE_CONFIG_FILE} oslo_messaging_rabbit amqp_durable_queues "False"
