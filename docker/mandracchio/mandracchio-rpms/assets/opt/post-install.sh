#!/bin/sh
set -x
echo "Harbor RPM Script Launching"

echo "Moving the payload into place"
/bin/cp -Rf /opt/payload/* /
/bin/rm -Rf /opt/payload

echo "Harbor RPM Script Complete"
