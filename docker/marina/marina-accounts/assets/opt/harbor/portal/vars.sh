#!/bin/bash
: ${PORTAL_DB_CA:="/run/harbor/auth/user/tls.ca"}
: ${PORTAL_DB_KEY:="/run/harbor/auth/user/tls.key"}
: ${PORTAL_DB_CERT:="/run/harbor/auth/user/tls.crt"}

: ${AUTH_PORTAL_KEYSTONE_PROJECT:="service"}
: ${AUTH_PORTAL_KEYSTONE_PROJECT_DOMAIN:="default"}
: ${AUTH_PORTAL_KEYSTONE_PROJECT_USER_ROLE:="admin"}
: ${AUTH_PORTAL_KEYSTONE_DOMAIN:="default"}
: ${AUTH_PORTAL_KEYSTONE_REGION:="RegionOne"}
