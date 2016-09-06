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
echo "${OS_DISTRO}: Writing ISO file to USB Key"
################################################################################

DOCKER_IMAGE=port/mandracchio-installer

IMAGE_NAME=harbor-host-7
IMAGE_ROOT=/srv/images/installer/images/images
DOCKER_IMAGE=port/mandracchio-installer
COMPRESSED_IMAGE_LOC="${IMAGE_ROOT}/installer.iso"

DOCKER_CONTAINER=$(docker run -d --privileged -v /dev:/dev:rw ${DOCKER_IMAGE})

docker exec ${DOCKER_CONTAINER} /bin/sh -c "dd bs=4M if=${COMPRESSED_IMAGE_LOC} of=/dev/sdc && sync"
