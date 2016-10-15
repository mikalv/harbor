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

set -e
: ${OS_DISTRO:="HarborOS: FreeIPA"}
echo "${OS_DISTRO}: Marina Kube FreeIPA Pod Starting"
################################################################################

(
  echo "${OS_DISTRO}: Marina Kube FreeIPA Config Starting"
  ##############################################################################
  until /usr/bin/init-harbor-ipa; do
    echo "${OS_DISTRO}: Script: init-harbor-ipa failed, retrying in 120s"
    ############################################################################
    sleep 120s
  done
  until /usr/bin/init-harbor-barbican-kra-secret; do
    echo "${OS_DISTRO}: Script: init-harbor-barbican-kra-secret failed, retrying in 120s"
    ############################################################################
    sleep 120s
  done
)&

echo "${OS_DISTRO}: Marina Kube FreeIPA Pod Starting"
################################################################################
exec /usr/bin/start-freeipa-server


echo "${OS_DISTRO}: Marina Kube Container has terminated"
################################################################################
