#!/bin/bash
set -e
echo "${OS_DISTRO}: Launching"
################################################################################
. /etc/os-container.env
. /opt/harbor/service-hosts.sh
. /opt/harbor/harbor-common.sh
. /opt/harbor/horizon/vars.sh


echo "${OS_DISTRO}: Testing environment"
################################################################################
/usr/bin/mysql-test
/opt/harbor/horizon/test-horizon-tls.sh


echo "${OS_DISTRO}: Configuring horizon"
################################################################################
/opt/harbor/horizon/config-horizon.sh


echo "${OS_DISTRO}: Configuring apache"
################################################################################
/opt/harbor/horizon/config-apache.sh


echo "${OS_DISTRO}: Priming horizon"
################################################################################
/opt/harbor/horizon/prime-horizon.sh


echo "${OS_DISTRO}: Adding API CA to container ca-bundle"
################################################################################
cat /run/harbor/auth/ssl/tls.ca >> /etc/ssl/certs/ca-bundle.crt


echo "${OS_DISTRO}: Launching Container Application"
################################################################################
exec /usr/sbin/httpd -D FOREGROUND
