


mkdir -p /etc/ipa
cp /run/harbor/auth/keytab/keytab /etc/ipa/portal.keytab
chown apache:apache /etc/ipa/portal.keytab

cp /run/harbor/auth/ssl/tls.ca /etc/pki/ca-trust/source/anchors/tls.pem
/bin/update-ca-trust
