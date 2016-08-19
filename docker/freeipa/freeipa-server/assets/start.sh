#!/bin/sh
exit 0


# ipa-server-install \
# --setup-dns \
# --realm=$(hostname -d | tr '[:lower:]' '[:upper:]')  \
# --domain=$(hostname -d) \
# --ds-password=password123 \
# --admin-password=password123 \
# --mkhomedir \
# --hostname=$(hostname -f) \
# --no-host-dns \
# --no-ntp \
# --no_hbac_allow \
# --ssh-trust-dns
