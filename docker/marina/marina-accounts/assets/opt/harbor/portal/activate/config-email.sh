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
: ${OS_DISTRO:="HarborOS: Auth"}
echo "${OS_DISTRO}: Starting email config"
################################################################################
. /etc/os-container.env
. /opt/harbor/service-hosts.sh
. /opt/harbor/harbor-common.sh
. /opt/harbor/portal/vars.sh


echo "${OS_DISTRO}: ${OPENSTACK_COMPONENT}: ${OPENSTACK_SUBCOMPONENT}: echo "${OS_DISTRO}:
################################################################################
ssmtp_cfg=/etc/ssmtp/ssmtp.conf
cat > $ssmtp_cfg <<EOF
root=${AUTH_PORTAL_DEFAULT_ADMIN_EMAIL}
mailhub=${AUTH_PORTAL_SMTP_HOST}:${AUTH_PORTAL_SMTP_PORT}
rewriteDomain=gmail.com
hostname=$(hostname -f)
UseTLS=Yes
UseSTARTTLS=Yes
AuthUser=${AUTH_PORTAL_SMTP_USER}
AuthPass=${AUTH_PORTAL_SMTP_PASS}
FromLineOverride=yes
TLS_CA_File=/etc/pki/tls/certs/ca-bundle.crt
EOF
ssmtp_aliases=/etc/ssmtp/revaliases
echo "root:${AUTH_PORTAL_DEFAULT_FROM_EMAIL}:${AUTH_PORTAL_SMTP_HOST}:${AUTH_PORTAL_SMTP_PORT}" >> $ssmtp_aliases



echo "${OS_DISTRO}: Setting UP EMAIL templates"
################################################################################
sed -i "s/{{ EMAIL }}/${AUTH_PORTAL_DEFAULT_FROM_EMAIL}/" /srv/mail/blank-slate/*
sed -i "s/{{ OS_DOMAIN }}/${OS_DOMAIN}/" /srv/mail/blank-slate/*
sed -i "s,{{ PORTAL_SERVICE_HOST }},${PORTAL_HOSTNAME}.${OS_DOMAIN}," /srv/mail/blank-slate/*
sed -i "s/{{ OS_DOMAIN }}/${OS_DOMAIN}/" /srv/mail/blank-slate/conv.html
