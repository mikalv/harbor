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
git clone ${OS_REPO_URL_1} -b ${OS_REPO_BRANCH_1} --depth 1 /opt/stack/${OS_COMP_1}


echo "${OS_DISTRO}: Installing ${OS_COMP}"
################################################################################
pip --no-cache-dir install /opt/stack/${OS_COMP_1}

cd /opt/stack/${OS_COMP_1}/contrib/heat_docker/
  python ./setup.py install
cd /


echo "${OS_DISTRO}: Cleaning up ${OS_COMP}"
################################################################################
rm -rf /opt/stack


################################################################################
echo "${OS_DISTRO}: Finished build ${OS_COMP}"
