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


IMAGE_ID="ami-59addf2a"
IMAGE_ID="ami-7ee89d69"

IMAGE_USER="harbor"
INSTANCE_TYPE="r3.xlarge"

KEY_PAIR_NAME=harbor-dev

aws ec2 delete-key-pair --key-name ${KEY_PAIR_NAME} || true
sudo chmod 0600 $HOME/.aws/${KEY_PAIR_NAME}.pem
sudo rm $HOME/.aws/${KEY_PAIR_NAME}.pem
aws ec2 create-key-pair --key-name ${KEY_PAIR_NAME} --query 'KeyMaterial' --output text > $HOME/.aws/${KEY_PAIR_NAME}.pem
chmod 0400 $HOME/.aws/${KEY_PAIR_NAME}.pem


TMP_JSON=/tmp/$(uuidgen).json
aws ec2 run-instances \
--image-id ${IMAGE_ID} \
--key-name ${KEY_PAIR_NAME} \
--instance-type ${INSTANCE_TYPE} \
--count 1 \
--block-device-mappings "VirtualName=/dev/sde,DeviceName=/dev/sde,Ebs={VolumeSize=120,DeleteOnTermination=false,VolumeType=gp2,Encrypted=true}" > ${TMP_JSON}
INSTANCE_ID=$(jq --raw-output '.Instances | .[0] | .InstanceId' ${TMP_JSON})
aws ec2 describe-instances --instance-ids ${INSTANCE_ID} > ${TMP_JSON}
INSTANCE_IP=$(jq --raw-output '.Reservations | .[0] | .Instances | .[0] | .PublicIpAddress' ${TMP_JSON})
INSTANCE_VOL=$(jq --raw-output '.Reservations | .[0] | .Instances | .[0] | .BlockDeviceMappings | .[1] | .Ebs | .VolumeId' ${TMP_JSON})

IMAGE_HOST_CMD="ssh -oStrictHostKeyChecking=no -i $HOME/.aws/${KEY_PAIR_NAME}.pem ${IMAGE_USER}@$INSTANCE_IP"
while ! ${IMAGE_HOST_CMD} ls
do
    sleep 10
    echo "Trying again..."
done
