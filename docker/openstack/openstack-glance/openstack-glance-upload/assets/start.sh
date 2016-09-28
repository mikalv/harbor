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
echo "${OS_DISTRO}: Launching"
################################################################################
. /etc/os-container.env
. /opt/harbor/service-hosts.sh
. /opt/harbor/glance/vars.sh


echo "${OS_DISTRO}: Testing service dependancies"
################################################################################
docker -H unix://var/run/docker.sock version


echo "${OS_DISTRO}: Authenticating with keystone"
################################################################################
. /opt/harbor/glance/manage/env-keystone-auth.sh


echo "${OS_DISTRO}: Getting glance admin endpoint"
################################################################################
export OS_IMAGE_URL="$(openstack endpoint list --service glance --interface admin -f value -c URL)"
echo "${OS_DISTRO}: Glance endpoint: ${OS_IMAGE_URL}"


# Image upload function
################################################################################
upload_docker_image () {
  IMAGE=$1
  IMAGE_ID=$(docker inspect -f {{.Id}} ${IMAGE})
  IMAGE_SIZE=$(docker inspect -f {{.VirtualSize}} ${IMAGE})
  #docker measures size in hard drive manufacter numbers...
  IMAGE_SIZE_MB="$(( (${IMAGE_SIZE} / 1000000) + 1 ))"
  IMAGE_SIZE_GB="$(( (${IMAGE_SIZE_MB} / 1024) + 1 ))"

  docker tag ${IMAGE} ${IMAGE}

  docker save ${IMAGE} | glance image-create \
      --architecture x86_64 \
      --visibility public \
      --name ${IMAGE} \
      --disk-format raw \
      --container-format docker \
      --min-ram 16 \
      --min-disk ${IMAGE_SIZE_GB} \
      --property docker-id=${IMAGE_ID} \
      --property docker-tag=${IMAGE}
}


tail -f /dev/null
echo "${OS_DISTRO}: Uploading images"
################################################################################
DOCKER_IMAGES="docker.io/nginx:latest \
               docker.io/ewindisch/cirros:latest \
               docker.io/port/intermodal-ubuntu:latest \
               docker.io/port/intermodal-centos:latest \
               docker.io/port/intermodal-ubuntu-murano:latest"

for DOCKER_IMAGE in $DOCKER_IMAGES; do
  docker pull ${DOCKER_IMAGE}
  ((glance image-list --property-filter docker-id=$(docker inspect -f {{.Id}} ${DOCKER_IMAGE}) | grep -q ${DOCKER_IMAGE}) && \
    echo "${OS_DISTRO}: Image is already loaded into glance") || upload_docker_image ${DOCKER_IMAGE}
done
