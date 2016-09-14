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

: ${DEBUG:="False"}

: ${DEFAULT_REGION:="HarborOS"}
: ${OS_DISTRO:="HarborOS"}

: ${SECRETS_DIR:="/var/run/harbor/secrets"}

: ${HARBOR_HOSTS_FILE:="/var/run/harbor/hosts"}
: ${HARBOR_RESOLV_FILE:="/var/run/harbor/resolv.conf"}


: ${AUTH_KEYSTONE_REGION:="RegionOne"}
: ${AUTH_SERVICE_KEYSTONE_ROLE:="service"}
: ${AUTH_SERVICE_KEYSTONE_PROJECT:="service"}
: ${AUTH_SERVICE_KEYSTONE_PROJECT_DOMAIN:="default"}
: ${AUTH_SERVICE_KEYSTONE_PROJECT_USER_ROLE:="admin"}
: ${AUTH_SERVICE_KEYSTONE_DOMAIN:="default"}
: ${AUTH_SERVICE_KEYSTONE_REGION:="${AUTH_KEYSTONE_REGION}"}
