#!/bin/sh
set -e
echo "Launching nginx for ${HARBOR_COMPONENT}"
exec nginx -g "daemon off;"
