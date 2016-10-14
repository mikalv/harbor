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
echo "${OS_DISTRO}: Configuring grafana"
################################################################################
. /etc/os-container.env
. /opt/harbor/service-hosts.sh
. /opt/harbor/harbor-common.sh
. /opt/harbor/gnocchi/vars.sh
PROC_CORES=$(grep -c ^processor /proc/cpuinfo)
: ${API_WORKERS:="$(( ( $PROC_CORES + 1 ) / 2))"}


################################################################################
check_required_vars GRAFANA_CONFIG_FILE \
                    GRAFANA_LDAP_CONFIG_FILE \
                    OS_DOMAIN \
                    MY_IP \
                    API_WORKERS \
                    GNOCCHI_GRAFANA_SERVICE_HOST \
                    AUTH_GNOCCHI_GRAFANA_SECRET_KEY \
                    FREEIPA_SERVICE_HOST \
                    GNOCCHI_DB_CERT \
                    AUTH_GNOCCHI_GRAFANA_LDAP_PASSWORD \
                    AUTH_GNOCCHI_GRAFANA_LDAP_USER \
                    GRAFANA_LDAP_BASE_DN \
                    GNOCCHI_DB_CA \
                    GNOCCHI_DB_CERT \
                    GNOCCHI_DB_KEY \
                    GNOCCHI_GRAFANA_SVC_PORT_LOCAL


################################################################################
mkdir -p $(dirname ${GRAFANA_CONFIG_FILE})


echo "${OS_DISTRO}: WEBSERVER"
################################################################################
crudini --set ${GRAFANA_CONFIG_FILE} server protocol "http"
crudini --set ${GRAFANA_CONFIG_FILE} server http_addr "127.0.0.1"
crudini --set ${GRAFANA_CONFIG_FILE} server http_port "${GNOCCHI_GRAFANA_SVC_PORT_LOCAL}"
crudini --set ${GRAFANA_CONFIG_FILE} server domain "${GNOCCHI_GRAFANA_SERVICE_HOST}"
crudini --set ${GRAFANA_CONFIG_FILE} server enforce_domain "false"
crudini --set ${GRAFANA_CONFIG_FILE} server root_url "https://%(domain)s/grafana"


echo "${OS_DISTRO}: AUTH"
################################################################################
crudini --set ${GRAFANA_CONFIG_FILE} auth.proxy enabled "true"
crudini --set ${GRAFANA_CONFIG_FILE} auth.proxy header_name "X-WEBAUTH-USER"
crudini --set ${GRAFANA_CONFIG_FILE} auth.proxy header_property "username"
crudini --set ${GRAFANA_CONFIG_FILE} auth.proxy auto_sign_up "false"
crudini --set ${GRAFANA_CONFIG_FILE} auth.basic enabled "false"
crudini --set ${GRAFANA_CONFIG_FILE} auth.ldap enabled "true"
crudini --set ${GRAFANA_CONFIG_FILE} auth.ldap config_file "/etc/grafana/ldap.toml"

echo "${OS_DISTRO}: LDAP"
################################################################################
cat > ${GRAFANA_LDAP_CONFIG_FILE} << EOF
# Set to true to log user information returned from LDAP
verbose_logging = true

[[servers]]
# Ldap server host (specify multiple hosts space separated)
host = "${FREEIPA_SERVICE_HOST}"
# Default port is 389 or 636 if use_ssl = true
port = 636
# Set to true if ldap server supports TLS
use_ssl = true
# set to true if you want to skip ssl cert validation
ssl_skip_verify = false
# set to the path to your root CA certificate or leave unset to use system defaults
root_ca_cert = "${GNOCCHI_DB_CERT}"

# Search user bind dn
bind_dn = "uid=${AUTH_GNOCCHI_GRAFANA_LDAP_USER},cn=users,cn=accounts,${GRAFANA_LDAP_BASE_DN}"
# Search user bind password
bind_password = '${AUTH_GNOCCHI_GRAFANA_LDAP_PASSWORD}'

# User search filter, for example "(cn=%s)" or "(sAMAccountName=%s)" or "(uid=%s)"
search_filter = "(uid=%s)"

# An array of base dns to search through
search_base_dns = ["cn=users,cn=accounts,${GRAFANA_LDAP_BASE_DN}"]

# In POSIX LDAP schemas, without memberOf attribute a secondary query must be made for groups.
# This is done by enabling group_search_filter below. You must also set member_of= "cn"
# in [servers.attributes] below.

## Group search filter, to retrieve the groups of which the user is a member (only set if memberOf attribute is not available)
# group_search_filter = "(&(objectClass=posixGroup)(memberUid=%s))"
## An array of the base DNs to search through for groups. Typically uses ou=groups
group_search_base_dns = ["cn=groups,cn=accounts,${GRAFANA_LDAP_BASE_DN}"]

# Specify names of the ldap attributes your ldap uses
[servers.attributes]
name = "givenName"
surname = "sn"
username = "uid"
member_of = "memberOf"
email =  "mail"

# Map ldap groups to grafana org roles
[[servers.group_mappings]]
group_dn = "cn=admins,cn=groups,cn=accounts,${GRAFANA_LDAP_BASE_DN}"
org_role = "Admin"
# The Grafana organization database id, optional, if left out the default org (id 1) will be used
# org_id = 1

# [[servers.group_mappings]]
# group_dn = "cn=ipausers,cn=groups,cn=accounts,$IPA_BASE_DN"
# org_role = "Editor"

[[servers.group_mappings]]
# If you want to match all (or no ldap groups) then you can use wildcard
group_dn = "*"
org_role = "Viewer"
EOF


echo "${OS_DISTRO}: DATABASE"
################################################################################
crudini --set ${GRAFANA_CONFIG_FILE} database type "postgres"
crudini --set ${GRAFANA_CONFIG_FILE} database host "${GRAFANA_DB_SERVICE_HOST_SVC}:${GRAFANA_DB_SERVICE_PORT}"
crudini --set ${GRAFANA_CONFIG_FILE} database name "${AUTH_GNOCCHI_GRAFANA_DB_NAME}"
crudini --set ${GRAFANA_CONFIG_FILE} database user "${AUTH_GNOCCHI_GRAFANA_DB_USER}"
crudini --set ${GRAFANA_CONFIG_FILE} database password "${AUTH_GNOCCHI_GRAFANA_DB_PASSWORD}"
crudini --set ${GRAFANA_CONFIG_FILE} database ssl_mode "disable"


echo "${OS_DISTRO}: EMAIL"
################################################################################
crudini --set ${GRAFANA_CONFIG_FILE} smtp enabled "true"
crudini --set ${GRAFANA_CONFIG_FILE} smtp host "${GRAFANA_SMTP_HOST}:${GRAFANA_SMTP_PORT}"
crudini --set ${GRAFANA_CONFIG_FILE} smtp user "${GRAFANA_SMTP_USER}"
crudini --set ${GRAFANA_CONFIG_FILE} smtp password "${GRAFANA_SMTP_PASS}"
crudini --set ${GRAFANA_CONFIG_FILE} smtp from_address "${GRAFANA_DEFAULT_ADMIN_EMAIL}"
crudini --set ${GRAFANA_CONFIG_FILE} emails welcome_email_on_sign_up "true"


echo "${OS_DISTRO}: LOGGING"
################################################################################
crudini --set ${GRAFANA_CONFIG_FILE} log mode "console"
crudini --set ${GRAFANA_CONFIG_FILE} log level "Info"
crudini --set ${GRAFANA_CONFIG_FILE} log.console level "Info"
crudini --set ${GRAFANA_CONFIG_FILE} analytics reporting_enabled "false"


echo "${OS_DISTRO}: Security"
################################################################################
crudini --set ${GRAFANA_CONFIG_FILE} security admin_user "admin"
# Fill the admin password with a junk value as we get users from ldap
crudini --set ${GRAFANA_CONFIG_FILE} security admin_password "$(uuidgen -r | tr -d '-')"
crudini --set ${GRAFANA_CONFIG_FILE} security secret_key "${AUTH_GNOCCHI_GRAFANA_SECRET_KEY}"
crudini --set ${GRAFANA_CONFIG_FILE} security login_remember_days '1'
crudini --set ${GRAFANA_CONFIG_FILE} security cookie_username "grafana_user"
crudini --set ${GRAFANA_CONFIG_FILE} security cookie_remember_name "grafana_remember"
crudini --set ${GRAFANA_CONFIG_FILE} security disable_gravatar "true"
# data source proxy whitelist (ip_or_domain:port seperated by spaces)
#crudini --set ${GRAFANA_CONFIG_FILE} security data_source_proxy_whitelist ""
