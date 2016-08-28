#!/bin/sh
set -x
echo "hello"
/usr/bin/harbor-service-manage-auth
tail -f /dev/null

harbor-service-update ipsilon
harbor-service-update keystone
harbor-service-update neutron
harbor-service-update horizon
