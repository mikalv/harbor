#!/bin/sh
set -e
set -x

cd /lib/systemd/system/sysinit.target.wants/

for i in *; do \
[ $i == systemd-tmpfiles-setup.service ] || rm -f $i; \
done;

rm -f /lib/systemd/system/multi-user.target.wants/*
rm -f /etc/systemd/system/*.wants/*
rm -f /lib/systemd/system/local-fs.target.wants/*
rm -f /lib/systemd/system/sockets.target.wants/*udev*
rm -f /lib/systemd/system/sockets.target.wants/*initctl*
rm -f /lib/systemd/system/basic.target.wants/*
rm -f /lib/systemd/system/anaconda.target.wants/*

rm -rfv /etc/systemd/system/multi-user.target.wants

mkdir -p /etc/systemd/system/container-up.target.wants

ln -s /etc/systemd/system/container-up.target.wants /etc/systemd/system/multi-user.target.wants

cd /usr/lib/systemd/system/
ls *domainname.service && \
(for i in *domainname.service; do
  ( rm -f /etc/systemd/system/$i
  ln -s /etc/systemd/system/dummy-service.service /etc/systemd/system/$i;
  sed -i 's,^ExecStart.*,ExecStart=/bin/true,'  $i)
done;) || true

systemctl set-default container-up.target

systemctl enable container-configure-first.service

# We might as well fix ping here - as this issue only seems to occur on Fedora Hosts
setcap cap_net_raw,cap_net_admin+p /usr/bin/ping || true
