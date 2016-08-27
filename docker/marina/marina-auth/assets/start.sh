#!/bin/sh
echo "Createing Loading Harbor Auth into vault"
/usr/bin/load-harbor-auth-into-vault.sh


echo "Created Service Secrets"
shutdown -h now
