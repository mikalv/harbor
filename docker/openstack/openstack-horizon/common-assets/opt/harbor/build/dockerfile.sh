#!/bin/bash

# Copyright 2016 Port Direct
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -x
set -e
echo "${OS_DISTRO}: Building ${OS_COMP}"
################################################################################
mkdir -p /opt/stack


echo "${OS_DISTRO}: Getting Sources for ${OS_COMP}"
################################################################################
git clone ${OS_REPO_URL} -b ${OS_REPO_BRANCH} --depth 1 /opt/stack/${OS_COMP}
git clone ${OS_REPO_URL_1} -b ${OS_REPO_BRANCH_1} --depth 1 /opt/stack/${OS_COMP_1}
git clone ${OS_REPO_URL_2} -b ${OS_REPO_BRANCH_2} --depth 1 /opt/stack/${OS_COMP_2}
git clone ${OS_REPO_URL_3} -b ${OS_REPO_BRANCH_3} --depth 1 /opt/stack/${OS_COMP_3}
git clone ${OS_REPO_URL_4} -b ${OS_REPO_BRANCH_4} --depth 1 /opt/${OS_COMP_4}
git clone ${OS_REPO_URL_5} -b ${OS_REPO_BRANCH_5} --depth 1 /opt/stack/${OS_COMP_5}
git clone ${OS_REPO_URL_6} -b ${OS_REPO_BRANCH_6} --depth 1 /opt/stack/${OS_COMP_6}
git clone ${OS_REPO_URL_7} -b ${OS_REPO_BRANCH_7} --depth 1 /opt/stack/${OS_COMP_7}
git clone ${OS_REPO_URL_8} -b ${OS_REPO_BRANCH_8} --depth 1 /opt/stack/${OS_COMP_8}
git clone ${OS_REPO_URL_9} -b ${OS_REPO_BRANCH_9} --depth 1 /opt/stack/${OS_COMP_9}


echo "${OS_DISTRO}: Sutting up source files ${OS_COMP}"
################################################################################
mkdir -p /opt/stack/${OS_COMP}/openstack_dashboard/themes/harbor/static
ln -s /opt/patternfly-sass/assets /opt/stack/${OS_COMP}/openstack_dashboard/themes/harbor/static/

cp -f /opt/stack/${OS_COMP_1}/neutron_lbaas_dashboard/enabled/_1481_project_ng_loadbalancersv2_panel.py \
  /opt/stack/horizon/openstack_dashboard/enabled/

cp /opt/stack/${OS_COMP_2}/muranodashboard/local/enabled/_50_murano.py \
  /opt/stack/${OS_COMP}/openstack_dashboard/enabled/

cp -a /opt/stack/${OS_COMP_3}/app_catalog/enabled/* \
  /opt/stack/${OS_COMP}/openstack_dashboard/enabled/


echo "${OS_DISTRO}: Installing ${OS_COMP}"
################################################################################
pip --no-cache-dir install /opt/stack/${OS_COMP}
pip --no-cache-dir install /opt/stack/${OS_COMP_1}
pip --no-cache-dir install /opt/stack/${OS_COMP_2}
pip --no-cache-dir install /opt/stack/${OS_COMP_3}
pip --no-cache-dir install /opt/stack/${OS_COMP_5}
pip --no-cache-dir install /opt/stack/${OS_COMP_6}
pip --no-cache-dir install /opt/stack/${OS_COMP_7}
pip --no-cache-dir install /opt/stack/${OS_COMP_8}
pip --no-cache-dir install /opt/stack/${OS_COMP_9}


echo "${OS_DISTRO}: Setting up user for ${OS_COMP}"
################################################################################
if [ "$OS_DISTRO" = "HarborOS-Alpine" ]; then
  addgroup ${OS_COMP} -g 1000
  adduser -u 1000 -D -s /bin/false -G ${OS_COMP} ${OS_COMP}
else
  groupadd ${OS_COMP} -g 1000
  adduser -u 1000 -g ${OS_COMP} --system ${OS_COMP}
fi;


echo "${OS_DISTRO}: Creating data dirs for ${OS_COMP}"
################################################################################
mkdir -p /home/${OS_COMP}
mkdir -p /etc/${OS_COMP}
mkdir -p /var/log/${OS_COMP}
mkdir -p /var/lib/${OS_COMP}

chown -R ${OS_COMP}:${OS_COMP} /home/${OS_COMP}
chown -R ${OS_COMP}:${OS_COMP} /etc/${OS_COMP}
chown -R ${OS_COMP}:${OS_COMP} /var/log/${OS_COMP}
chown -R ${OS_COMP}:${OS_COMP} /var/lib/${OS_COMP}


################################################################################
echo "${OS_DISTRO}: Finished installing ${OS_COMP}"
