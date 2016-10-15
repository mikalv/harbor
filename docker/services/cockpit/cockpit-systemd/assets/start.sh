#!/bin/bash
echo "${OS_DISTRO}: Launching container application"
################################################################################
HOST_SSH_USER=harbor
HOST_SSH_PASSWORD=password

echo "${OS_DISTRO}: Setting up user: ${HOST_SSH_USER}"
################################################################################
groupadd ${HOST_SSH_USER} -g 1000
adduser -u 1000 -g ${HOST_SSH_USER} --create-home ${HOST_SSH_USER}
usermod -a -G wheel harbor
echo ${HOST_SSH_USER}:${HOST_SSH_PASSWORD} | chpasswd
systemctl unmask systemd-logind.service
systemctl restart systemd-logind.service
rm -f /run/nologin

echo "${OS_DISTRO}: Starting cockpit"
################################################################################
systemctl restart cockpit.service
