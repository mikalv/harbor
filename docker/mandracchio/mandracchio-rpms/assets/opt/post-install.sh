#!/bin/sh

echo "Harbor RPM Script Launching"

echo "Moving the payload into place"
/bin/cp -Rf /payload/* /
/bin/rm -Rf /payload

echo "Harbor RPM Script Complete"
