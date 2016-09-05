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
set -x
cd ~
rm -rf /srv/images/aws
rpm-ostree-toolbox imagefactory \
      --virtnetwork public \
      --ostreerepo /srv/repo \
      --tdl /srv/mandracchio/base.tdl \
      -c /srv/mandracchio/config.ini \
      -i raw \
      -k /srv/mandracchio/aws.ks \
      -o /srv/images/aws


IMAGE_NAME=harbor-host-7
IMAGE_ROOT=/srv/images/aws/images

cd ${IMAGE_ROOT}

# MOUNT_ROOT=/tmp/${IMAGE_NAME}/working-mount
# OFFSET=$(expr $(fdisk -l ${IMAGE_ROOT}/${IMAGE_NAME}.raw  | grep ${IMAGE_ROOT}/${IMAGE_NAME}.raw | awk '{ print $2 }' | tail -n 1) \* 512)
# OFFSET_BOOT=$(expr $(fdisk -l ${IMAGE_ROOT}/${IMAGE_NAME}.raw  | grep ${IMAGE_ROOT}/${IMAGE_NAME}.raw | awk '{ print $3 }' | tail -n 2 | head -n1 ) \* 512)
# OFFSET_BOOT_END=$(expr $(fdisk -l ${IMAGE_ROOT}/${IMAGE_NAME}.raw  | grep ${IMAGE_ROOT}/${IMAGE_NAME}.raw | awk '{ print $4 }' | tail -n 2 | head -n1 ) \* 512)
# mkdir -p ${MOUNT_ROOT}
# mount -t xfs -o offset=${OFFSET} ${IMAGE_ROOT}/${IMAGE_NAME}.raw ${MOUNT_ROOT}
#
# mkdir -p ${MOUNT_ROOT}/boot
# mount -t ext4 -o offset=${OFFSET_BOOT} ${IMAGE_ROOT}/${IMAGE_NAME}.raw ${MOUNT_ROOT}/boot
#
# cat > ${MOUNT_ROOT}/etc/os-release <<EOF
# NAME="Harbor Linux"
# VERSION="7 (Core)"
# ID="centos"
# ID_LIKE="rhel centos"
# VERSION_ID="7"
# PRETTY_NAME="Harbor Linux"
# ANSI_COLOR="0;31"
# CPE_NAME="cpe:/o:centos:centos:7"
# HOME_URL="https://port.direct"
# BUG_REPORT_URL="https://port.direct/"
#
# CENTOS_MANTISBT_PROJECT="CentOS-7"
# CENTOS_MANTISBT_PROJECT_VERSION="7"
# REDHAT_SUPPORT_PRODUCT="centos"
# REDHAT_SUPPORT_PRODUCT_VERSION="7"
# EOF
#
# cat > ${MOUNT_ROOT}/etc/fstab <<EOF
# #
# # /etc/fstab
# # Created by anaconda on Thu Aug 18 14:43:47 2016
# #
# # Accessible filesystems, by reference, are maintained under '/dev/disk'
# # See man pages fstab(5), findfs(8), mount(8) and/or blkid(8) for more info
# #
# /dev/sda2	    /                       xfs     defaults        0 0
# /dev/sda1     /boot                   ext4    defaults        1 2
# EOF
#
#
# umount ${MOUNT_ROOT}

gzip ${IMAGE_NAME}.raw
rm -f ${IMAGE_NAME}.qcow*
