#!/bin/bash
set -e
echo "${OS_DISTRO}: Configuring logging"
################################################################################
. /etc/os-container.env
. /opt/harbor/service-hosts.sh
. /opt/harbor/harbor-common.sh
. /opt/harbor/keystone/vars.sh


################################################################################
check_required_vars KEYSTONE_CONFIG_FILE \
                    OS_DOMAIN


################################################################################
crudini --set ${KEYSTONE_CONFIG_FILE} DEFAULT use_syslog "False"
crudini --set ${KEYSTONE_CONFIG_FILE} DEFAULT logging_exception_prefix "%(color)s%(asctime)s.%(msecs)03d TRACE %(name)s %(instance)s"
crudini --set ${KEYSTONE_CONFIG_FILE} DEFAULT logging_debug_format_suffix "from (pid=%(process)d) %(funcName)s %(pathname)s:%(lineno)d"
crudini --set ${KEYSTONE_CONFIG_FILE} DEFAULT logging_default_format_string "%(asctime)s.%(msecs)03d %(color)s%(levelname)s %(name)s [-%(color)s] %(instance)s%(color)s%(message)s"
crudini --set ${KEYSTONE_CONFIG_FILE} DEFAULT logging_context_format_string "%(asctime)s.%(msecs)03d %(color)s%(levelname)s %(name)s [%(request_id)s %(user_name)s %(project_id)s%(color)s] %(instance)s%(color)s%(message)s"
