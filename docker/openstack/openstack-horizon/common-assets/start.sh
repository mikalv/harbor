#!/bin/sh
echo "hello"
tail -f /dev/null
cfg=/opt/stack/horizon/openstack_dashboard/local/local_settings.py
cp -f /opt/stack/horizon/openstack_dashboard/local/local_settings.py.example $cfg

sed -i "s/OPENSTACK_HOST = \"127.0.0.1\"/OPENSTACK_HOST = \"${EXPOSED_IP}\"/g" $cfg

#tail -f /dev/null


/opt/stack/horizon/manage.py runserver 0.0.0.0:80



mysql -h ${KEYSTONE_MARIADB_SERVICE_HOST_SVC} \
      --port ${KEYSTONE_MARIADB_SERVICE_PORT} \
      -u ${AUTH_KEYSTONE_MARIADB_USER} \
      -p"${AUTH_KEYSTONE_MARIADB_PASSWORD}" \
      --ssl-key /run/harbor/auth/user/tls.key \
      --ssl-cert /run/harbor/auth/user/tls.crt \
      --ssl-ca /run/harbor/auth/user/tls.ca \
      --secure-auth \
      ${AUTH_KEYSTONE_MARIADB_DATABASE}
