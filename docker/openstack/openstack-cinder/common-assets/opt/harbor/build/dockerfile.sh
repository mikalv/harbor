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


set -x
set -e
mkdir -p /opt/stack

git clone ${OS_REPO_URL} -b ${OS_REPO_BRANCH} --depth 1 /opt/stack/${OS_COMP}

pip --no-cache-dir install /opt/stack/${OS_COMP}

mkdir -p /etc/${OS_COMP}/volumes
mkdir -p  /opt/stack/${OS_COMP}/etc/${OS_COMP}/
cp -rf /opt/stack/${OS_COMP}/etc/${OS_COMP}/* /etc/${OS_COMP}/

mkdir -p /var/log/${OS_COMP}
mkdir -p /var/lib/${OS_COMP}/lock
mkdir -p /var/lib/${OS_COMP}/instances

if [ "$OS_DISTRO" = "HarborOS-Alpine" ]; then
  addgroup ${OS_COMP} -g 1000
  adduser -u 1000 -D -s /bin/false -G ${OS_COMP} ${OS_COMP}
  ln -s /usr/sbin/iscsid /sbin/iscsid
else
  groupadd ${OS_COMP} -g 1000
  adduser -u 1000 -g ${OS_COMP} --system  ${OS_COMP}
fi;

mkdir -p /home/${OS_COMP}
chown -R ${OS_COMP}:${OS_COMP} /home/${OS_COMP}

chown -R ${OS_COMP}:${OS_COMP} /etc/${OS_COMP}
chown -R ${OS_COMP}:${OS_COMP} /var/log/${OS_COMP}
chown -R ${OS_COMP}:${OS_COMP} /var/lib/${OS_COMP}

mkdir -p /var/cache/${OS_COMP}
chown -R ${OS_COMP}:${OS_COMP} /var/cache/${OS_COMP}
