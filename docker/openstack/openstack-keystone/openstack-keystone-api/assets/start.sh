#!/bin/bash
set -e
echo "${OS_DISTRO}: Launching"
################################################################################
/opt/harbor/config-keystone.sh


echo "${OS_DISTRO}: Tailing inifinity"
################################################################################
tail -f /dev/null
