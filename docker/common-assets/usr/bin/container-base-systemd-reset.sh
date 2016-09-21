#!/bin/sh

# Copyright 2016 Port Direct
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

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
ln -s /usr/lib/systemd/system/container-up.target /etc/systemd/system/default.target
ln -s /usr/lib/systemd/system/container-configure-first.service /etc/systemd/system/container-up.target.wants/container-configure-first.service

cd /usr/lib/systemd/system/
ls *domainname.service && \
(for i in *domainname.service; do
  ( rm -f /etc/systemd/system/$i
  ln -s /etc/systemd/system/dummy-service.service /etc/systemd/system/$i;
  sed -i 's,^ExecStart.*,ExecStart=/bin/true,'  $i)
done;) || true


# We might as well fix ping here - as this issue only seems to occur on Fedora Hosts
setcap cap_net_raw,cap_net_admin+p /usr/bin/ping || true
