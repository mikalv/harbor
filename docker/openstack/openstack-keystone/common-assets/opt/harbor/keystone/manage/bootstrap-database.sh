#!/bin/bash
set -e
echo "${OS_DISTRO}: Bootstrapping database"
################################################################################
. /etc/os-container.env
. /opt/harbor/service-hosts.sh
. /opt/harbor/harbor-common.sh
. /opt/harbor/keystone/vars.sh


################################################################################
check_required_vars KEYSTONE_CONFIG_FILE\
                    AUTH_KEYSTONE_ADMIN_USER \
                    AUTH_KEYSTONE_ADMIN_PASSWORD \
                    AUTH_KEYSTONE_ADMIN_PROJECT \
                    KEYSTONE_API_SERVICE_HOST_SVC \
                    KEYSTONE_API_SERVICE_HOST


################################################################################
su -s /bin/sh -c "keystone-manage --config-file=${KEYSTONE_CONFIG_FILE} --debug db_sync" keystone
su -s /bin/sh -c "keystone-manage --config-file=${KEYSTONE_CONFIG_FILE} --debug bootstrap \
                  --bootstrap-username ${AUTH_KEYSTONE_ADMIN_USER} \
                  --bootstrap-password ${AUTH_KEYSTONE_ADMIN_PASSWORD} \
                  --bootstrap-project-name ${AUTH_KEYSTONE_ADMIN_PROJECT} \
                  --bootstrap-admin-url https://${KEYSTONE_API_SERVICE_HOST_SVC}:35357/v3 \
                  --bootstrap-public-url https://${KEYSTONE_API_SERVICE_HOST}/v3 \
                  --bootstrap-internal-url https://${KEYSTONE_API_SERVICE_HOST_SVC}:5000/v3 \
                  --bootstrap-region-id RegionOne" keystone
