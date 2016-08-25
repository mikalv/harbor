#!/bin/sh
echo "Createing Loading Harbor Auth into vault"
/usr/bin/load-harbor-auth-into-vault.sh


echo "Created Service Secrets"
tail -f /dev/null

shutdown -h now
