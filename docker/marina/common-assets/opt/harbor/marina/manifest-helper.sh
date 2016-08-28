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

LOCAL_ENV=/tmp/$(uuidgen).env
rm -f ${LOCAL_ENV}
touch ${LOCAL_ENV}

KUBE_MANIFESTS_DIR=/etc/kubernetes/manifests
TEMPLATE_DIR=/opt/harbor/kubernetes/templates
MANIFESTS_WORK_DIR=/tmp/harbor/working


HARBOR_KUBE_OPENSTACK_CONFIG=/run/harbor/kube_openstack/config
LOCAL_ENV_LIST="$LOCAL_ENV_LIST HARBOR_KUBE_OPENSTACK_CONFIG"

HARBOR_HOSTS_FILE=/var/run/harbor/hosts
HARBOR_RESOLV_FILE=/var/run/harbor/resolv.conf
LOCAL_ENV_LIST="$LOCAL_ENV_LIST HARBOR_HOSTS_FILE HARBOR_RESOLV_FILE"

prep_manifest () {
  manifest_group=$1
  manifest=$2
  MANIFEST_WORK_FILE="$MANIFESTS_WORK_DIR/$manifest_group/$manifest"
  MANIFEST_FILE="$KUBE_MANIFESTS_DIR/$manifest_group-$manifest"
  mkdir -p $MANIFESTS_WORK_DIR/$manifest_group
  cat $TEMPLATE_DIR/$manifest_group/$manifest > $MANIFEST_WORK_FILE
  for LOCAL_ENV in $LOCAL_ENV_LIST; do
    if [ "$manifest" == "secrets.yaml" ]; then
      LOCAL_ENV_RAW_VALUE=$(set | grep ^$LOCAL_ENV= | awk -F "$LOCAL_ENV=" '{ print $2 }')
      LOCAL_ENV_VALUE=$( printf ${LOCAL_ENV}=${LOCAL_ENV_RAW_VALUE} | base64 --wrap=0 )
    else
      LOCAL_ENV_VALUE=$(set | grep ^$LOCAL_ENV= | awk -F "$LOCAL_ENV=" '{ print $2 }')
    fi;
    sed -i "s&{{ $LOCAL_ENV }}&${LOCAL_ENV_VALUE}&g" $MANIFEST_WORK_FILE
  done
  for LOCAL_ENV in $SERVICE_HOST_LIST; do
    if [ "$manifest" == "secrets.yaml" ]; then
      LOCAL_ENV_RAW_VALUE=$(set | grep ^$LOCAL_ENV= | awk -F "$LOCAL_ENV=" '{ print $2 }')
      LOCAL_ENV_VALUE=$( printf ${LOCAL_ENV}=${LOCAL_ENV_RAW_VALUE} | base64 --wrap=0 )
    else
      LOCAL_ENV_VALUE=$(set | grep ^$LOCAL_ENV= | awk -F "$LOCAL_ENV=" '{ print $2 }')
    fi;
    sed -i "s&{{ $SERVICE_HOST }}&${LOCAL_ENV_VALUE}&g" $MANIFEST_WORK_FILE
  done
  for LOCAL_ENV in $SERVICE_HOSTS_ENV_LIST; do
    if [ "$manifest" == "secrets.yaml" ]; then
      LOCAL_ENV_RAW_VALUE=$(set | grep ^$LOCAL_ENV= | awk -F "$LOCAL_ENV=" '{ print $2 }')
      LOCAL_ENV_VALUE=$( printf ${LOCAL_ENV}=${LOCAL_ENV_RAW_VALUE} | base64 --wrap=0 )
    else
      LOCAL_ENV_VALUE=$(set | grep ^$LOCAL_ENV= | awk -F "$LOCAL_ENV=" '{ print $2 }')
    fi;
    sed -i "s&{{ $SERVICE_HOST }}&${LOCAL_ENV_VALUE}&g" $MANIFEST_WORK_FILE
  done
  cat $MANIFEST_WORK_FILE
}


list_manifests () {
  MANIFEST_GROUP=$1
  COMPONENTS="$(ls ${TEMPLATE_DIR}/${MANIFEST_GROUP} | tr '\n' ' ' )"
  echo $COMPONENTS
}

prep_manifests () {
  MANIFEST_GROUP=$1
  MANIFESTS="$(list_manifests $1)"
  for MANIFEST in $MANIFESTS; do
    prep_manifest $MANIFEST_GROUP $MANIFEST
  done
}

load_manifest () {
  manifest_group=$1
  manifest=$2.yaml
  MANIFEST_WORK_FILE="$MANIFESTS_WORK_DIR/$manifest_group/$manifest"
  cat $MANIFEST_WORK_FILE
  kubectl create -f $MANIFEST_WORK_FILE
}



label_nodes () {
  COMPONENT=$1
  KUBE_NODES=$(kubectl get nodes --no-headers| awk -F ' ' '{print $1}')
  for KUBE_NODE in $KUBE_NODES
  do
    kubectl label --overwrite node ${KUBE_NODE} openstack-${COMPONENT}='true'
  done
}
