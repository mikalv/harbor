#!/bin/bash

: ${FLEXVOLUME_DB_CA:="/run/harbor/auth/user/tls.ca"}
: ${FLEXVOLUME_DB_KEY:="/run/harbor/auth/user/tls.key"}
: ${FLEXVOLUME_DB_CERT:="/run/harbor/auth/user/tls.crt"}

: ${AUTH_FLEXVOLUME_KEYSTONE_PROJECT:="service"}
: ${AUTH_FLEXVOLUME_KEYSTONE_PROJECT_DOMAIN:="default"}
: ${AUTH_FLEXVOLUME_KEYSTONE_PROJECT_USER_ROLE:="admin"}
: ${AUTH_FLEXVOLUME_KEYSTONE_DOMAIN:="default"}
: ${AUTH_FLEXVOLUME_KEYSTONE_REGION:="RegionOne"}
