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
OS_DISTRO="HarborOS-Fedora"
echo "${OS_DISTRO}: FreeIPA starting"
################################################################################
mkdir -p /run/ipa

HOSTNAME=$( uname -n )


echo "${OS_DISTRO}: Reloading Systemd"
################################################################################
cat /etc/systemd/system/systemd-hostnamed.service > /usr/lib/systemd/system/systemd-hostnamed.service
systemctl daemon-reload


#echo "${OS_DISTRO}: Helper functions"
################################################################################
update_server_ip_address () {
  CURRENT_IP=$( dig +short -t A $HOSTNAME )
  MY_IP=''
  if [ -f /run/ipa/ipa-server-ip ] ; then
    MY_IP=$( cat /run/ipa/ipa-server-ip )
  fi
  MY_IP=${MY_IP:-$( /sbin/ip addr show | awk '/inet .*global/ { split($2,a,"/"); print a[1]; }' | head -1 )}
  if [ "$CURRENT_IP" == "$MY_IP" ] ; then
    return
  fi

  echo "${OS_DISTRO}: updating $HOSTNAME to $MY_IP"
  kdestroy -A
  kinit -k
  (
    echo "update add $HOSTNAME 180 A $MY_IP"
    echo "update delete $HOSTNAME A $CURRENT_IP"
    echo "send"
    echo "quit"
  ) | nsupdate -g
  kdestroy -A

  while true ; do
    NEW_IP=$( dig +short -t A $HOSTNAME )
    if [ "$NEW_IP" == "$MY_IP" ] ; then
      break
    fi
    sleep 1
  done
}




DATA=/data
DATA_TEMPLATE=/data-template
echo "${OS_DISTRO}: Checking data volume"
################################################################################
if [ -f "$DATA/volume-version" ] ; then
  DATA_VERSION=$(cat $DATA/volume-version)
  IMAGE_VERSION=$(cat /etc/volume-version)
  echo "${OS_DISTRO}: Image data version ${IMAGE_VERSION}, volume version ${DATA_VERSION}"
  ################################################################################
  if ! [ "$DATA_VERSION" == "$IMAGE_VERSION" ] ; then
    if [ -x /usr/sbin/ipa-volume-upgrade-$DATA_VERSION-$IMAGE_VERSION ] ; then
      echo "Migrating $DATA data volume version $DATA_VERSION to $IMAGE_VERSION."
      if /usr/sbin/ipa-volume-upgrade-$DATA_VERSION-$IMAGE_VERSION ; then
        cat /etc/volume-version > $DATA/volume-version
      else
        echo "Migration of $DATA volume to version $IMAGE_VERSION failed."
        exit 1
      fi
    fi
  fi
else
  echo "${OS_DISTRO}: No prior data volume version found"
fi
if [ -f "$DATA/build-id" ] ; then
  echo "${OS_DISTRO}: Image build-id version: $(cat $DATA/build-id)"
  ################################################################################
  if ! cmp -s $DATA/build-id $DATA_TEMPLATE/build-id ; then
    echo "FreeIPA server is already configured but with different version, volume update."
    ( cd $DATA_TEMPLATE && find * | while read f ; do
      if [ -d "$DATA_TEMPLATE/$f" ] && [ -f "$DATA/$f" ] ; then
        echo "Removing file $DATA/$f, replacing with directory from $DATA_TEMPLATE."
        rm -f "$DATA/$f"
      fi
      if ! [ -e $DATA/$f ] ; then
        tar cf - $f | ( cd $DATA && tar xf - )
      fi
      done
    )
    sha256sum -c /etc/volume-data-autoupdate 2> /dev/null | awk -F': ' '/OK$/ { print $1 }' \
      | while read f ; do
        rm -f "$DATA/$f"
        if [ -e "$DATA_TEMPLATE/$f" ] ; then
          ( cd $DATA_TEMPLATE && tar cf - "./$f" ) | ( cd $DATA && tar xvf - )
        fi
      done
    cat /etc/volume-data-list | while read i ; do
      if [ -e $DATA_TEMPLATE$i -a -e $DATA$i ] ; then
        chown --reference=$DATA_TEMPLATE$i $DATA$i
        chmod --reference=$DATA_TEMPLATE$i $DATA$i
      fi
    done
  fi
else
  echo "${OS_DISTRO}: No prior data volume build version found"
fi


echo "${OS_DISTRO}: Installing IPA Server if required"
################################################################################
if [ -f /etc/ipa/ca.crt ] ; then
  echo "The FreeIPA server was already configured."
else
  COMMAND=ipa-server-install
  RUN_CMD="/usr/sbin/ipa-server-install"
  if ! [ -f /data/ipa-server-install-options ] ; then
    echo "Install options /data/ipa-server-install-options not found"
    exit 1
  fi


  echo "${OS_DISTRO}: setting up data dirs"
  ################################################################################
  if [ -f "$DATA/hostname" ] ; then
    STORED_HOSTNAME="$( cat $DATA/hostname )"
    if [ "$HOSTNAME" != "$STORED_HOSTNAME" ] ; then
      echo "Invocation error: use -h $STORED_HOSTNAME to match the configured hostname." >&2
      exit 15
    fi
  else
    echo "$HOSTNAME" > "$DATA/hostname"
  fi


  echo "${OS_DISTRO}: setting up symbolic links"
  (
    cd /data && \
    grep '/$' /etc/volume-data-list | sed 's!^!.!' | xargs mkdir -p && \
    grep -v '/$' /etc/volume-data-list | xargs dirname | sed 's!^!.!' | xargs mkdir -p && \
    grep -v '/$' /etc/volume-data-list | sed 's!^!.!' | xargs touch
  ) || exit 1

  echo "${OS_DISTRO}: removing files in the volume-data-mv-list"
  cat /etc/volume-data-mv-list | xargs -l1 rm -v -f

  HOSTNAME_SHORT=${HOSTNAME%%.*}
  DOMAIN=${HOSTNAME#*.}
  if [ "$HOSTNAME_SHORT.$DOMAIN" != "$HOSTNAME" ] ; then
    echo "The container has to have fully-qualified hostname defined."
    exit 1
  fi

  echo "${OS_DISTRO}: Ensuring /var/log/httpd exists"
  ################################################################################
  mkdir -p /var/log/httpd

  echo "${OS_DISTRO}: Running Freeipa Installer"
  ################################################################################
  IPA_INSTALL_OPTIONS="$(xargs -a <(cat /data/$COMMAND-options ))"
  ($RUN_CMD $IPA_INSTALL_OPTIONS) || ( echo "FreeIPA server configuration failed."; exit 1 )


  echo "${OS_DISTRO}: Setting Up data volume"
  ################################################################################
  cat /etc/volume-data-mv-list | while read DATA_VOL_ASSET ; do
    rm -rf /data${DATA_VOL_ASSET}
    if [ -e ${DATA_VOL_ASSET} ] ; then
      mv ${DATA_VOL_ASSET} /data${DATA_VOL_ASSET}
      ln -sf ${DATA}${DATA_VOL_ASSET} ${DATA_VOL_ASSET}
    fi
  done
  cat /etc/volume-version > /data/volume-version


  echo "${OS_DISTRO}: Patching krb5.conf"
  ################################################################################
  sed -i 's/default_ccache_name/# default_ccache_name/' ${DATA}/etc/krb5.conf


  echo "${OS_DISTRO}: Restarting FreeIPA"
  ################################################################################
  until /usr/sbin/ipactl restart
  do
    echo "Attempting to restart FreeIPA"
    sleep 10s
  done

  echo "${OS_DISTRO}: Running ipa-kra-installer"
  ################################################################################
  AUTH_FREEIPA_DS_PASSWORD="$(cat ${DATA}/$COMMAND-options | grep -m1 "^--ds-password=" | awk -F '=' '{ print $2 }')"
  until ipa-kra-install --unattended --password=${AUTH_FREEIPA_DS_PASSWORD}
  do
    echo "Attempting to install ipa-kra"
    sleep 10s
  done
  AUTH_FREEIPA_DS_PASSWORD=""

fi


echo "${OS_DISTRO}: Enabling Services"
################################################################################
systemctl enable ipa-server-update-self-ip-address.service
systemctl enable ipa.service
#systemctl enable container-tail-journal.service



echo "${OS_DISTRO}: Updating Server IP if required"
################################################################################
if systemctl is-active -q named-pkcs11 || [ -f /run/ipa/ipa-server-ip ] ; then
  /bin/cp -f /etc/resolv.conf ${DATA}/etc/resolv.conf.ipa
  while ! host -t A $HOSTNAME > /dev/null ; do
    sleep 1
  done
  update_server_ip_address
else
  echo "FreeIPA DNS server not active."
fi
