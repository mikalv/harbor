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
echo "${OS_DISTRO}: Bootstrapping ${OS_DOMAIN} users"
################################################################################
. /etc/os-container.env
. /opt/harbor/service-hosts.sh
. /opt/harbor/harbor-common.sh
. /opt/harbor/keystone/vars.sh
. /opt/harbor/keystone/manage/env-keystone-admin-auth.sh


################################################################################
check_required_vars OS_DOMAIN \
                    AUTH_SERVICE_KEYSTONE_PROJECT \
                    AUTH_SERVICE_KEYSTONE_PROJECT_DOMAIN \
                    AUTH_SERVICE_KEYSTONE_PROJECT_USER_ROLE \
                    AUTH_SERVICE_KEYSTONE_DOMAIN \
                    AUTH_SERVICE_KEYSTONE_REGION \
                    AUTH_SERVICE_KEYSTONE_ROLE


echo "${OS_DISTRO}: defining functions"
################################################################################
# These come from https://github.com/openstack-dev/devstack/blob/master/lib/keystone
# Credit to https://github.com/openstack-dev/devstack/blob/master/MAINTAINERS.rst

# Grab a numbered field from python prettytable output
# Fields are numbered starting with 1
# Reverse syntax is supported: -1 is the last field, -2 is second to last, etc.
# get_field field-number
function get_field {
    local data field
    while read data; do
        if [ "$1" -lt 0 ]; then
            field="(\$(NF$1))"
        else
            field="\$$(($1 + 1))"
        fi
        echo "$data" | awk -F'[ \t]*\\|[ \t]*' "{print $field}"
    done
}

# Gets or adds user role to domain
# Usage: get_or_add_user_domain_role <role> <user> <domain>
function get_or_add_user_domain_role {
    local user_role_id
    # Gets user role id
    user_role_id=$(openstack role list \
        --user $2 \
        --column "ID" \
        --domain $3 \
        --column "Name" \
        | grep " $1 " | get_field 1)
    if [[ -z "$user_role_id" ]]; then
        # Adds role to user and get it
        openstack role add $1 \
            --user $2 \
            --domain $3
        user_role_id=$(openstack role list \
            --user $2 \
            --column "ID" \
            --domain $3 \
            --column "Name" \
            | grep " $1 " | get_field 1)
    fi
    echo $user_role_id
}


# Gets or creates a domain
# Usage: get_or_create_domain <name> <description>
function get_or_create_domain {
    local domain_id
    # Gets domain id
    domain_id=$(
        # Gets domain id
        openstack domain show $1 \
            -f value -c id 2>/dev/null ||
        # Creates new domain
        openstack domain create $1 \
            --description "$2" \
            -f value -c id
    )
    echo $domain_id
}


# Gets or creates project
# Usage: get_or_create_project <name> <domain>
function get_or_create_project {
    local project_id
    project_id=$(
        # Creates new project with --or-show
        openstack project create $1 \
            --domain=$2 \
            --or-show -f value -c id
    )
    echo $project_id
}


# Gets or creates role
# Usage: get_or_create_role <name>
function get_or_create_role {
    local role_id
    role_id=$(
        # Creates role with --or-show
        openstack role create $1 \
            --or-show -f value -c id
    )
    echo $role_id
}

# Gets or creates group
# Usage: get_or_create_group <groupname> <domain> [<description>]
function get_or_create_group {
    local desc="${3:-}"
    local group_id
    # Gets group id
    group_id=$(
        # Creates new group with --or-show
        openstack group create $1 \
            --domain $2 --description "$desc" --or-show \
            -f value -c id
    )
    echo $group_id
}


# Gets or adds group role to project
# Usage: get_or_add_group_project_role <role> <group> <project>
function get_or_add_group_project_role {
    local group_role_id
    # Gets group role id
    group_role_id=$(openstack role list \
        --group $2 \
        --project $3 \
        -c "ID" -f value)
    if [[ -z "$group_role_id" ]]; then
        # Adds role to group and get it
        openstack role add $1 \
            --group $2 \
            --project $3
        group_role_id=$(openstack role list \
            --group $2 \
            --project $3 \
            -c "ID" -f value)
    fi
    echo $group_role_id
}


# The keystone bootstrapping process (performed via keystone-manage bootstrap)
# creates an admin user, admin role and admin project. As a sanity check
# we exercise the CLI to retrieve the IDs for these values.
admin_project=$(openstack project show "admin" -f value -c id)
admin_user=$(openstack user show "admin" -f value -c id)
admin_role=$(openstack role show "admin" -f value -c id)

echo "Make sure that the admin user is admin of the default/v2 domain"
get_or_add_user_domain_role $admin_role $admin_user default

echo "Create service project/role"
get_or_create_domain "$AUTH_SERVICE_KEYSTONE_DOMAIN"
AUTH_SERVICE_KEYSTONE_PROJECT_ID=$(get_or_create_project "$AUTH_SERVICE_KEYSTONE_PROJECT" "$AUTH_SERVICE_KEYSTONE_DOMAIN")


echo "Service role, so service users do not have to be admins"
AUTH_SERVICE_KEYSTONE_ROLE_ID=$(get_or_create_role ${AUTH_SERVICE_KEYSTONE_ROLE})

echo "The ResellerAdmin role is used by Nova and Ceilometer so we need to keep it."
# The admin role in swift allows a user to act as an admin for their project,
# but ResellerAdmin is needed for a user to act as any project. The name of this
# role is also configurable in swift-proxy.conf
get_or_create_role ResellerAdmin

echo "The Member role is used by Horizon and Swift so we need to keep it:"
member_role=$(get_or_create_role "Member")

echo "Managing admin and service groups"
admin_group=$(get_or_create_group "admins" "default" "openstack admin group")
AUTH_SERVICE_KEYSTONE_GROUP_ID=$(get_or_create_group "service" "default" "opensatck service group")
get_or_add_group_project_role $admin_role $admin_group $admin_project
get_or_add_group_project_role ${AUTH_SERVICE_KEYSTONE_ROLE_ID} ${AUTH_SERVICE_KEYSTONE_GROUP_ID} ${AUTH_SERVICE_KEYSTONE_PROJECT_ID}
