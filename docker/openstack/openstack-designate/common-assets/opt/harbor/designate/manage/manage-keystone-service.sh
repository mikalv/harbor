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
echo "${OS_DISTRO}: Managing keystone service and endpoints"
################################################################################
. /etc/os-container.env
. /opt/harbor/service-hosts.sh
. /opt/harbor/harbor-common.sh
. /opt/harbor/designate/vars.sh
. /opt/harbor/designate/manage/env-keystone-admin-auth.sh


################################################################################
check_required_vars OS_DOMAIN \
                    AUTH_DESIGNATE_KEYSTONE_REGION \
                    DESIGNATE_API_SERVICE_HOST_SVC \
                    DESIGNATE_API_SERVICE_HOST \
                    DESIGNATE_API_SVC_PORT


################################################################################
for OS_SERVICE_NAME in designate; do
  OS_SVC_ENDPOINTS="PUBLIC ADMIN INTERNAL"

  if [ "$OS_SERVICE_NAME" == "designate" ]; then
    OS_SERVICE_TYPE="dns"
    OS_SERVICE_DESC="${OS_DOMAIN}: ${OS_SERVICE_NAME} (${OS_SERVICE_TYPE}) service"
    OS_SVC_ENDPOINT_INTERNAL="https://${DESIGNATE_API_SERVICE_HOST_SVC}/"
    OS_SVC_ENDPOINT_ADMIN="https://${DESIGNATE_API_SERVICE_HOST_SVC}:${DESIGNATE_API_SVC_PORT}/"
    OS_SVC_ENDPOINT_PUBLIC="https://${DESIGNATE_API_SERVICE_HOST}/"
  fi



  ################################################################################
  check_required_vars OS_DOMAIN \
                      OS_SERVICE_NAME \
                      OS_SERVICE_TYPE \
                      OS_SERVICE_DESC \
                      OS_SVC_ENDPOINTS \
                      OS_SVC_ENDPOINT_INTERNAL \
                      OS_SVC_ENDPOINT_ADMIN \
                      OS_SVC_ENDPOINT_PUBLIC


  echo "${OS_DISTRO}: Managing keystone service"
  ################################################################################
  unset OS_SERVICE_ID
  OS_SERVICE_ID=$( openstack service list -f csv --quote none | \
                    grep ",${OS_SERVICE_NAME},${OS_SERVICE_TYPE}$" | \
                      sed -e "s/,${OS_SERVICE_NAME},${OS_SERVICE_TYPE}//g" )
  if [[ -z ${OS_SERVICE_ID} ]]; then
    OS_SERVICE_ID=$(openstack service create -f value -c id \
                    --name="${OS_SERVICE_NAME}" \
                    --description "${OS_SERVICE_DESC}" \
                    --enable \
                    "${OS_SERVICE_TYPE}")
  fi
  export OS_SERVICE_ID

  check_required_vars OS_SERVICE_ID
  openstack service show ${OS_SERVICE_ID}


  echo "${OS_DISTRO}: Managing keystone endpoints"
  ################################################################################
  for OS_SVC_ENDPOINT in ${OS_SVC_ENDPOINTS}; do
    unset OS_ENDPOINT_ID
    unset OS_ENDPOINT_UPDATE
    CURRENT_OS_SVC_ENDPOINT_VAR="OS_SVC_ENDPOINT_${OS_SVC_ENDPOINT}"
    CURRENT_OS_SVC_ENDPOINT_IFACE="$(echo ${OS_SVC_ENDPOINT} | tr '[:upper:]' '[:lower:]')"
    CURRENT_OS_SVC_ENDPOINT="${!CURRENT_OS_SVC_ENDPOINT_VAR}"
    OS_ENDPOINT_ID=$( openstack endpoint list  -f csv --quote none | \
                      grep "^[a-z0-9]*,${AUTH_DESIGNATE_KEYSTONE_REGION},${OS_SERVICE_NAME},${OS_SERVICE_TYPE},True,${CURRENT_OS_SVC_ENDPOINT_IFACE}," | \
                      awk -F ',' '{ print $1 }' )
    if [[ ${OS_ENDPOINT_ID} ]]; then
      OS_ENDPOINT_URL_CURRENT=$(openstack endpoint show ${OS_ENDPOINT_ID} --f value -c url)
      if [[ "${OS_ENDPOINT_URL_CURRENT}" == "${CURRENT_OS_SVC_ENDPOINT}" ]]; then
        echo "Endpoints Match: no action required"
        OS_ENDPOINT_UPDATE="False"
      else
        echo "Endpoints Dont Match: removing existing entries"
        openstack endpoint delete ${OS_ENDPOINT_ID}
        OS_ENDPOINT_UPDATE="True"
      fi
    else
      OS_ENDPOINT_UPDATE="True"
    fi
    check_required_vars OS_ENDPOINT_UPDATE

    if [[ "${OS_ENDPOINT_UPDATE}" == "True" ]]; then
      OS_ENDPOINT_ID=$( openstack endpoint create -f value -c id \
        --region="${AUTH_DESIGNATE_KEYSTONE_REGION}" \
        "${OS_SERVICE_ID}" \
        ${CURRENT_OS_SVC_ENDPOINT_IFACE} \
        "${CURRENT_OS_SVC_ENDPOINT}" )
    fi
    check_required_vars OS_ENDPOINT_ID

    openstack endpoint show ${OS_ENDPOINT_ID}
  done

done
