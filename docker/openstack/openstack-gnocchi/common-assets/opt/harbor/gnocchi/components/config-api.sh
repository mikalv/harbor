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
echo "${OS_DISTRO}: Configuring api"
################################################################################
. /etc/os-container.env
. /opt/harbor/service-hosts.sh
. /opt/harbor/harbor-common.sh
. /opt/harbor/gnocchi/vars.sh
PROC_CORES=$(grep -c ^processor /proc/cpuinfo)
: ${API_WORKERS:="$(( ( $PROC_CORES + 1 ) / 2))"}


################################################################################
check_required_vars GNOCCHI_CONFIG_FILE \
                    OS_DOMAIN \
                    GNOCCHI_API_SVC_PORT \
                    MY_IP \
                    API_WORKERS \
                    GNOCCHI_UWSGI_CONFIG_FILE


echo "${OS_DISTRO}: WSGI"
################################################################################
crudini --set ${GNOCCHI_UWSGI_CONFIG_FILE} uwsgi http "127.0.0.1:$GNOCCHI_API_SVC_PORT"
crudini --set ${GNOCCHI_UWSGI_CONFIG_FILE} uwsgi wsgi-file "/usr/lib/python2.7/site-packages/gnocchi/rest/app.wsgi"
# This is running standalone
crudini --set ${GNOCCHI_UWSGI_CONFIG_FILE} uwsgi master "true"
# Set die-on-term & exit-on-reload so that uwsgi shuts down
crudini --set ${GNOCCHI_UWSGI_CONFIG_FILE} uwsgi die-on-term "true"
crudini --set ${GNOCCHI_UWSGI_CONFIG_FILE} uwsgi exit-on-reload "true"
crudini --set ${GNOCCHI_UWSGI_CONFIG_FILE} uwsgi threads "32"
crudini --set ${GNOCCHI_UWSGI_CONFIG_FILE} uwsgi processes "${API_WORKERS}"
crudini --set ${GNOCCHI_UWSGI_CONFIG_FILE} uwsgi enable-threads "true"
# uwsgi doesn not require a plugin when installed with pip
#crudini --set ${GNOCCHI_UWSGI_CONFIG_FILE} uwsgi plugins "python"
# uwsgi recommends this to prevent thundering herd on accept.
crudini --set ${GNOCCHI_UWSGI_CONFIG_FILE} uwsgi thunder-lock "true"
# Override the default size for headers from the 4k default.
crudini --set ${GNOCCHI_UWSGI_CONFIG_FILE} uwsgi buffer-size "65535"
# Make sure the client doesn't try to re-use the connection.
crudini --set ${GNOCCHI_UWSGI_CONFIG_FILE} uwsgi add-header "Connection: close"
# Don't share rados resources and python-requests globals between processes
crudini --set ${GNOCCHI_UWSGI_CONFIG_FILE} uwsgi lazy-apps "true"
