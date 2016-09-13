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
echo "${OS_DISTRO}: Priming horizon"
################################################################################
. /etc/os-container.env
. /opt/harbor/service-hosts.sh
. /opt/harbor/harbor-common.sh
. /opt/harbor/horizon/vars.sh


################################################################################
check_required_vars OS_DOMAIN


echo "${OS_DISTRO}: Collecting static files"
################################################################################
/opt/stack/horizon/manage.py collectstatic --noinput


echo "${OS_DISTRO}: Compilong Magnum Messages"
################################################################################
cd /usr/lib/python2.7/site-packages/magnum_ui && \
  DJANGO_SETTINGS_MODULE=openstack_dashboard.settings /opt/stack/horizon/manage.py compilemessages


echo "${OS_DISTRO}: Collecting compressing assets"
################################################################################
/opt/stack/horizon/manage.py compress
