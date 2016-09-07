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
echo "${OS_DISTRO}: Starting Harbor Image upload"
################################################################################
set -x
IMAGE_NAME=harbor-host-7
IMAGE_ROOT=/srv/images/aws/images
DOCKER_IMAGE=port/mandracchio-image-aws
COMPRESSED_IMAGE_LOC="${IMAGE_ROOT}/${IMAGE_NAME}.raw.gz"


echo "${OS_DISTRO}: Defining cloud provider specific vars"
################################################################################
UPSTREAM_IMAGE_USER="fedora"
IMAGE_LOADER_INSTANCE_TYPE="t2.medium"
DISC_LETTER=e
KEY_PAIR_NAME=image-upload

echo "${OS_DISTRO}: Selecting AMI to use for image transfer"
################################################################################
AWS_REGION=$(crudini --get /root/.aws/config default region)
if [ "${AWS_REGION}" == "us-east-1" ] ; then
  UPSTREAM_IMAGE_ID="ami-cf6204d8"
elif [ "${AWS_REGION}" == "eu-west-1" ] ; then
  UPSTREAM_IMAGE_ID="ami-4dbec93e"
else
  echo "Region not currently supported - run script manually"
fi


echo "${OS_DISTRO}: Creating key-pair for image upload"
################################################################################
aws ec2 delete-key-pair --key-name ${KEY_PAIR_NAME} || true
aws ec2 create-key-pair --key-name ${KEY_PAIR_NAME} --query 'KeyMaterial' --output text > /root/.aws/${KEY_PAIR_NAME}.pem
chmod 0400 /root/.aws/${KEY_PAIR_NAME}.pem


echo "${OS_DISTRO}: Launching Instance"
################################################################################
aws ec2 run-instances \
--image-id ${UPSTREAM_IMAGE_ID} \
--key-name ${KEY_PAIR_NAME} \
--instance-type ${IMAGE_LOADER_INSTANCE_TYPE} \
--count 1 \
--block-device-mappings "VirtualName=/dev/sd${DISC_LETTER},DeviceName=/dev/sd${DISC_LETTER},Ebs={VolumeSize=12,DeleteOnTermination=false,VolumeType=gp2,Encrypted=true}" > /tmp/build-instance.json
INSTANCE_ID=$(jq --raw-output '.Instances | .[0] | .InstanceId' /tmp/build-instance.json)
aws ec2 describe-instances --instance-ids ${INSTANCE_ID} > /tmp/harbor-build-instance.json
INSTANCE_IP=$(jq --raw-output '.Reservations | .[0] | .Instances | .[0] | .PublicIpAddress' /tmp/harbor-build-instance.json)
INSTANCE_VOL=$(jq --raw-output '.Reservations | .[0] | .Instances | .[0] | .BlockDeviceMappings | .[1] | .Ebs | .VolumeId' /tmp/harbor-build-instance.json)


echo "${OS_DISTRO}: Waiting for host to come up and start docker"
################################################################################
IMAGE_HOST_CMD="ssh -oStrictHostKeyChecking=no -i /root/.aws/${KEY_PAIR_NAME}.pem ${UPSTREAM_IMAGE_USER}@$INSTANCE_IP sudo"
while ! ${IMAGE_HOST_CMD} systemctl start docker
do
    sleep 10
    echo "Trying again..."
done


echo "${OS_DISTRO}: Launching docker image on remote instance"
################################################################################
DOCKER_IMAGE_CONTAINER=$(${IMAGE_HOST_CMD} docker run -d --privileged -v /dev:/dev:rw ${DOCKER_IMAGE})


echo "${OS_DISTRO}: Copying data to volume"
################################################################################
${IMAGE_HOST_CMD} docker exec -t ${DOCKER_IMAGE_CONTAINER} /bin/sh -c \"gzip -d -v -c ${COMPRESSED_IMAGE_LOC} \| dd of=/dev/xvd${DISC_LETTER}\"


echo "${OS_DISTRO}: detaching volume from instance"
################################################################################
aws ec2 detach-volume --volume-id ${INSTANCE_VOL}


echo "${OS_DISTRO}: snapshotting volume"
################################################################################
aws ec2 create-snapshot --description "Harbor Host @ $(date -R -u)" --volume-id ${INSTANCE_VOL} > /tmp/harbor-build-snapshot.json
SNAPSHOT_ID=$(jq --raw-output '.SnapshotId' /tmp/harbor-build-snapshot.json)
CURRENT_PROGRESS=0
until [ "$CURRENT_PROGRESS" == "100%" ]; do
  sleep 10
  aws ec2 describe-snapshots --snapshot-ids $SNAPSHOT_ID > /tmp/import-image-task.json
  CURRENT_PROGRESS=$(jq --raw-output '.Snapshots | .[0] | .Progress' /tmp/import-image-task.json)
  CURRENT_STATUS=$(jq --raw-output '.Snapshots | .[0] | .State' /tmp/import-image-task.json)
  echo "${CURRENT_STATUS}: ${CURRENT_PROGRESS}"
done


echo "${OS_DISTRO}: removing instance"
################################################################################
aws ec2 terminate-instances --instance-ids ${INSTANCE_ID}


echo "${OS_DISTRO}: registering image"
################################################################################
aws ec2 register-image \
--name "Harbor Host 7" \
--virtualization-type hvm \
--block-device-mappings "DeviceName=/dev/sda1,Ebs={SnapshotId=${SNAPSHOT_ID},VolumeSize=12,DeleteOnTermination=true,VolumeType=gp2}" \
--root-device-name /dev/sda1 \
--architecture x86_64 > /tmp/import-image-ami.json
AMI_ID=$(jq --raw-output '.ImageId' /tmp/import-image-ami.json)


echo "${OS_DISTRO}: Finished Image Upload"
################################################################################
echo "${OS_DISTRO}: Registered AMI: ${AMI_ID}"
