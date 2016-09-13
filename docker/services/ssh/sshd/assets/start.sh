#!/bin/bash

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
echo "${OS_DISTRO}: Launching SSH server"
################################################################################

HOST_SSH_USER="harbor"

echo "${OS_DISTRO}: Loading user config into container"
################################################################################
cat /host/etc/shadow | grep "^${HOST_SSH_USER}" >> /etc/shadow
cat /host/etc/passwd | grep "^${HOST_SSH_USER}" >> /etc/passwd
cat /host/etc/group | grep "^${HOST_SSH_USER}" >> /etc/group


echo "${OS_DISTRO}: Generating keys"
################################################################################
/usr/bin/ssh-keygen -A


echo "${OS_DISTRO}: Launching container application"
################################################################################
exec /usr/sbin/sshd -D

/usr/bin/docker run -it --net=host -v /etc/passwd:/host/etc/passwd:ro -v /etc/shadow:/host/etc/shadow:ro -v /etc/group:/host/etc/group:ro port/alpine bash
