#!/bin/bash
cd tmp

rpm-ostree compose --repo=/srv/repo tree /opt/mandracchio/harbor-host.json

ln -s /srv/repo/ /var/www/html/repo

rm -f /etc/httpd/conf.d/welcome.conf
