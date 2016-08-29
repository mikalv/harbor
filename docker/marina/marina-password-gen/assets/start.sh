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

set -e
touch /etc/os-container.env

AUTH_FILES='/etc/harbor/harbor-auth.conf /etc/harbor/auth.conf'
# This iterates though config files looking for matches in the form:
# {{ PASSWORD_[0-9][0-9] }} and replaces them with the approprate length output
# from pwgen
for AUTH_FILE in $AUTH_FILES; do
    echo "Processing $AUTH_FILE"
    if [ -w $AUTH_FILE ] ; then
      echo "file is writeable"
      crudini --get $AUTH_FILE | while read -r section ; do
          echo "Processing $AUTH_FILE $section"
          crudini --get $AUTH_FILE $section | while read -r param ; do
            PARAM="$(crudini --get $AUTH_FILE $section $param)"
            if echo "$PARAM" | grep '^{{ PASSWORD_[0-9][0-9] }}' >/dev/null ; then
              PW_LENGTH=$(echo $PARAM | awk -F 'PASSWORD_' '{ print $2}'| awk '{ print $1}')
              PW_LENGTH_FIX=$(($PW_LENGTH + 1))
              crudini --set $AUTH_FILE $section $param "$(harbor-gen-password $PW_LENGTH $PW_LENGTH_FIX)"
            fi
          done
      done
    else
      echo "file either does not esist or is not writable - skipping"
    fi
done
