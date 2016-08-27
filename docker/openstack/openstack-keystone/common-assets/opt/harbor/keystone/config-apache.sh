#!/bin/bash
set -e
echo "${OS_DISTRO}: Configuring apache"
################################################################################
. /etc/os-container.env
. /opt/harbor/service-hosts.sh
. /opt/harbor/harbor-common.sh
. /opt/harbor/keystone/vars.sh


################################################################################
check_required_vars KEYSTONE_APACHE_CONFIG_FILE \
                    KEYSTONE_APACHE_MELLON_CONFIG_FILE \
                    KEYSTONE_API_SERVICE_HOST \
                    KEYSTONE_API_SERVICE_HOST_SVC \
                    KEYSTONE_API_TLS_CERT \
                    KEYSTONE_API_TLS_KEY \
                    KEYSTONE_API_TLS_CA \
                    KEYSTONE_MELLON_ACTIVE \
                    KEYSTONE_MELLON_SP_METADATA \
                    KEYSTONE_MELLON_SP_TLS_KEY \
                    KEYSTONE_MELLON_SP_TLS_CERT \
                    KEYSTONE_MELLON_IDP_METADATA


################################################################################
sed -i "s|{{ KEYSTONE_API_SERVICE_HOST }}|${KEYSTONE_API_SERVICE_HOST}|g" ${KEYSTONE_APACHE_CONFIG_FILE}
sed -i "s|{{ KEYSTONE_API_SERVICE_HOST_SVC }}|${KEYSTONE_API_SERVICE_HOST_SVC}|g" ${KEYSTONE_APACHE_CONFIG_FILE}


################################################################################
sed -i "s|{{ KEYSTONE_API_TLS_CERT }}|${KEYSTONE_API_TLS_CERT}|g" ${KEYSTONE_APACHE_CONFIG_FILE}
sed -i "s|{{ KEYSTONE_API_TLS_KEY }}|${KEYSTONE_API_TLS_KEY}|g" ${KEYSTONE_APACHE_CONFIG_FILE}
sed -i "s|{{ KEYSTONE_API_TLS_CA }}|${KEYSTONE_API_TLS_CA}|g" ${KEYSTONE_APACHE_CONFIG_FILE}


################################################################################
if [ "${KEYSTONE_MELLON_ACTIVE}" == "True" ] ; then
  echo "${OS_DISTRO}: Enabling Mellon config"
  sed -i "s|{{ KEYSTONE_MELLON_CONF }}|Include ${KEYSTONE_APACHE_MELLON_CONFIG_FILE}|g" ${KEYSTONE_APACHE_CONFIG_FILE}
else
  echo "${OS_DISTRO}: Disableing Mellon config"
  sed -i "s|{{ KEYSTONE_MELLON_CONF }}||g" ${KEYSTONE_APACHE_CONFIG_FILE}
fi
sed -i "s|{{ KEYSTONE_MELLON_SP_METADATA }}|${KEYSTONE_MELLON_SP_METADATA}|g" ${KEYSTONE_APACHE_CONFIG_FILE}
sed -i "s|{{ KEYSTONE_MELLON_SP_TLS_KEY }}|${KEYSTONE_MELLON_SP_TLS_KEY}|g" ${KEYSTONE_APACHE_CONFIG_FILE}
sed -i "s|{{ KEYSTONE_MELLON_SP_TLS_CERT }}|${KEYSTONE_MELLON_SP_TLS_CERT}|g" ${KEYSTONE_APACHE_CONFIG_FILE}
sed -i "s|{{ KEYSTONE_MELLON_IDP_METADATA }}|${KEYSTONE_MELLON_IDP_METADATA}|g" ${KEYSTONE_APACHE_CONFIG_FILE}
