#!/bin/bash
echo hello
tail -f /dev/null




################################################################################
echo "${OS_DISTRO}: ${OPENSTACK_COMPONENT}: ${OPENSTACK_SUBCOMPONENT}: FreeIPA Portal Install"
################################################################################
/opt/harbor/accounts/config-email.sh
/opt/harbor/accounts/retrieve-keytab.sh



################################################################################
echo "${OS_DISTRO}: ${OPENSTACK_COMPONENT}: ${OPENSTACK_SUBCOMPONENT}: Launching Webserver"
################################################################################
exec httpd -D FOREGROUND
