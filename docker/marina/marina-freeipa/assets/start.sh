#!/bin/sh
set -x
/usr/bin/patch-freeipa-server &
/usr/bin/start-freeipa-server
echo "script exit status $?"
echo "Container Terminating"
