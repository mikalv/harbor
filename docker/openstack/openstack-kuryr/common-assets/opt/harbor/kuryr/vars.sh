#!/bin/bash
: ${KURYR_CONFIG_FILE:="/etc/kuryr/kuryr.conf"}

: ${KURYR_CAPABILITY_SCOPE:="local"}

: ${KURYR_DB_CA:="/run/harbor/auth/user/tls.ca"}
: ${KURYR_DB_KEY:="/run/harbor/auth/user/tls.key"}
: ${KURYR_DB_CERT:="/run/harbor/auth/user/tls.crt"}

: ${AUTH_KURYR_KEYSTONE_PROJECT:="service"}
: ${AUTH_KURYR_KEYSTONE_PROJECT_DOMAIN:="default"}
: ${AUTH_KURYR_KEYSTONE_PROJECT_USER_ROLE:="admin"}
: ${AUTH_KURYR_KEYSTONE_DOMAIN:="default"}
: ${AUTH_KURYR_KEYSTONE_REGION:="RegionOne"}

: ${KURYR_PORT:="23750"}

: ${KURYR_THREADS:="1"}
: ${KURYR_PROCESSES:="1"}

: ${UPLINK_NET:="169.254.128.0/30"}
: ${UPLINK_NET_NAME:="uplink"}
: ${UPLINK_IP_CONT:="169.254.128.2"}
: ${UPLINK_IP_HOST:="169.254.128.1"}

: ${UPLINK_KUBE_NAMESPACE:="os-node"}

: ${SUBNET_POOL:="192.168.0.0/16"}
: ${FLANNEL_NET:="172.16.0.0/16"}
: ${SERVICE_CLUSTER_IP_RANGE:="10.10.0.0/24"}

: ${KURYR_POOL_PREFIX:="10.90.0.0/16"}
: ${KURYR_POOL_PREFIX_LEN:="24"}
: ${KURYR_POOL_NAME:="kuryr"}


: ${PUBLIC_GATEWAY_IP:="10.80.0.1/12"}
: ${EXTERNAL_BRIDGE:="br-ex"}
