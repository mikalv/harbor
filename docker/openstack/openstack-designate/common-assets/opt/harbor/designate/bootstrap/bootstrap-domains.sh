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
echo "${OS_DISTRO}: Bootstrapping powerdns"
################################################################################
. /etc/os-container.env
. /opt/harbor/service-hosts.sh
. /opt/harbor/harbor-common.sh
. /opt/harbor/designate/vars.sh
. /opt/harbor/designate/manage/env-keystone-auth.sh


################################################################################
check_required_vars OS_DOMAIN
unset OS_DOMAIN_NAME

################################################################################
designate domain-get ex.${OS_DOMAIN}. || designate domain-create \
      --name ex.${OS_DOMAIN}. \
      --email admin@${OS_DOMAIN} \
      --ttl 300 \
      --description "Managed Floating IP Domain, populated from Neutron/Nova events"

DESIGNATE_MANAGED_DNS_DOMAIN_ID=$(designate domain-get ex.${OS_DOMAIN}. -f value -c id)
if [ "$DESIGNATE_MANAGED_DNS_DOMAIN_ID" == "None" ]; then exit 1; fi


designate domain-get in.${OS_DOMAIN}. || designate domain-create \
      --name in.${OS_DOMAIN}. \
      --email admin@${OS_DOMAIN} \
      --ttl 300 \
      --description "Managed Internal Domain, populated from Neutron/Nova events"

DESIGNATE_INTERNAL_DNS_DOMAIN_ID=$(designate domain-get in.${OS_DOMAIN}. -f value -c id)
if [ "$DESIGNATE_INTERNAL_DNS_DOMAIN_ID" == "None" ]; then exit 1; fi


designate domain-get ${OS_DOMAIN}. || designate domain-create \
      --name ${OS_DOMAIN}. \
      --email admin@${OS_DOMAIN} \
      --ttl 3600 \
      --description "Primary DNS Domain"

DESIGNATE_DNS_DOMAIN_ID=$(designate domain-get ${OS_DOMAIN}. -f value -c id)
if [ "$DESIGNATE_DNS_DOMAIN_ID" == "None" ]; then exit 1; fi
