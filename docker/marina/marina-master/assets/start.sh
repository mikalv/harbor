#!/bin/sh
set -x
echo "hello"
/usr/bin/harbor-service-manage-auth
tail -f /dev/null
