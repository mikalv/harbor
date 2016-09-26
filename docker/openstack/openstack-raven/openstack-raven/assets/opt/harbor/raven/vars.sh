#!/bin/bash
: ${RAVEN_DB_CA:="/run/harbor/auth/user/tls.ca"}
: ${RAVEN_DB_KEY:="/run/harbor/auth/user/tls.key"}
: ${RAVEN_DB_CERT:="/run/harbor/auth/user/tls.crt"}

: ${AUTH_RAVEN_KEYSTONE_PROJECT:="service"}
: ${AUTH_RAVEN_KEYSTONE_PROJECT_DOMAIN:="default"}
: ${AUTH_RAVEN_KEYSTONE_PROJECT_USER_ROLE:="admin"}
: ${AUTH_RAVEN_KEYSTONE_DOMAIN:="default"}
: ${AUTH_RAVEN_KEYSTONE_REGION:="RegionOne"}

: ${RAVEN_CONFIG_FILE:="/etc/raven/raven.conf"}

: ${RAVEN_ROUTER_NAME:="raven-default-router"}
: ${PUBLIC_NET_NAME:="ext-net"}
