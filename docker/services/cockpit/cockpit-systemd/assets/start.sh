#!/bin/bash




echo "${OS_DISTRO}: Launching container application"
################################################################################

HOST_SSH_USER=harbor

echo "${OS_DISTRO}: Setting up user for ${HOST_SSH_USER}"
################################################################################
if [ "$OS_DISTRO" = "HarborOS-Alpine" ]; then
  addgroup ${HOST_SSH_USER} -g 1000
  adduser -u 1000 -D -s /bin/bash -G ${HOST_SSH_USER} ${HOST_SSH_USER}
else
  groupadd ${HOST_SSH_USER} -g 1000
  adduser -u 1000 -g ${HOST_SSH_USER} --create-home ${HOST_SSH_USER}
  usermod -a -G wheel harbor
  echo ${HOST_SSH_USER}:chpasswd | chpasswd
fi;
systemctl unmask systemd-logind.service
systemctl restart systemd-logind.service
rm -f /run/nologin
systemctl restart cockpit.service



docker run \
      --net=host \
      -t \
      -d \
      -v="/sys/fs/cgroup:/sys/fs/cgroup:ro" \
      -v="/tmp/run:/run:rw" \
      -v="/tmp/run/lock:/run/lock:rw" \
      -v="/var/run/docker.sock:/var/run/docker.sock:rw" \
      -v="/var/lib/harbor/cockpit/home:/home:rw" \
      -v="/var/lib/harbor/cockpit/data:/data:rw" \
      --security-opt="seccomp=unconfined" \
      port/cockpit-shell:latest
