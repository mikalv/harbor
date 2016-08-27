#!/bin/sh
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
              crudini --set $AUTH_FILE $section $param "$(pwgen $PW_LENGTH 1)"
            fi
          done
      done
    else
      echo "file either does not esist or is not writable - skipping"
    fi
done
