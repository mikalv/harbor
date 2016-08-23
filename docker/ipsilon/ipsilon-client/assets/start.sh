#!/bin/sh
exec "$@"

if [ -f /etc/ipa/ca.crt ] ; then
  ################################################################################
  echo "${OS_DISTRO}: IPA: CA Cert found @ /etc/ipa/ca.crt, assuming that we are already enrolled"
  ################################################################################
else
  ################################################################################
  echo "${OS_DISTRO}: IPA: Installing client"
  ################################################################################
  check_required_vars OS_DOMAIN \
                      FREEIPA_SERVICE_HOST \
                      FREEIPA_HOST_ADMIN_USER \
                      FREEIPA_HOST_ADMIN_PASSWORD

  ipa-client-install \
      --domain=${OS_DOMAIN} \
      --server=${FREEIPA_SERVICE_HOST} \
      --realm=$( echo ${OS_DOMAIN}  | tr '[:lower:]' '[:upper:]' ) \
      --principal=${FREEIPA_HOST_ADMIN_USER} \
      --password=${FREEIPA_HOST_ADMIN_PASSWORD} \
      --hostname=$(hostname -s).${OS_DOMAIN} \
      --unattended \
      --force \
      --force-join \
      --no-ntp \
      --request-cert \
      --mkhomedir  \
      --ssh-trust-dns \
      --enable-dns-updates
fi
