#!/bin/bash
: ${OVN_L3_MODE:="False"}


: ${NEUTRON_MARIADB_SERVICE_PORT:="3308"}
: ${NEUTRON_DB_CA:="/run/harbor/auth/user/tls.ca"}
: ${NEUTRON_DB_KEY:="/run/harbor/auth/user/tls.key"}
: ${NEUTRON_DB_CERT:="/run/harbor/auth/user/tls.crt"}
: ${NEUTRON_API_TLS_CA:="/run/harbor/auth/ssl/tls.ca"}
: ${NEUTRON_API_TLS_KEY:="/run/harbor/auth/ssl/tls.key"}
: ${NEUTRON_API_TLS_CERT:="/run/harbor/auth/ssl/tls.crt"}
: ${NEUTRON_API_SVC_PORT:="9696"}
: ${NEUTRON_MARIADB_SERVICE_HOST_SVC:="${NEUTRON_API_SERVICE_HOSTNAME}-db.${NEUTRON_SERVICE_NAMESPACE}.svc.$OS_DOMAIN"}

: ${AUTH_NEUTRON_KEYSTONE_PROJECT:="service"}
: ${AUTH_NEUTRON_KEYSTONE_PROJECT_DOMAIN:="default"}
: ${AUTH_NEUTRON_KEYSTONE_PROJECT_USER_ROLE:="admin"}
: ${AUTH_NEUTRON_KEYSTONE_DOMAIN:="default"}
: ${AUTH_NEUTRON_KEYSTONE_REGION:="RegionOne"}

: ${AUTH_NOVA_KEYSTONE_PROJECT:="service"}
: ${AUTH_NOVA_KEYSTONE_PROJECT_DOMAIN:="default"}
: ${AUTH_NOVA_KEYSTONE_DOMAIN:="default"}
: ${AUTH_NOVA_KEYSTONE_REGION:="RegionOne"}



: ${NEUTRON_CONFIG_FILE:="/etc/neutron/neutron.conf"}
: ${NEUTRON_ML2_CONFIG_FILE:="/etc/neutron/plugins/ml2/ml2_conf.ini"}
: ${NEUTRON_L3_CONFIG_FILE:="/etc/neutron/l3_agent.ini"}
: ${NEUTRON_LBAAS_CONFIG_FILE:="/etc/neutron/neutron_lbaas.conf"}
: ${NEUTRON_LBAAS_AGENT_CONFIG_FILE:="/etc/neutron/services/loadbalancer/haproxy/lbaas_agent.ini"}
: ${NEUTRON_METADATA_CONFIG_FILE:="/etc/neutron/metadata_agent.ini"}
: ${NEUTRON_METADATA_OVN_CONFIG_FILE:="/etc/neutron/ovn_metadata_agent.ini"}


: ${LBAAS_PROVIDER:="haproxy"}


: ${NOVA_METADATA_SVC_PORT:="8775"}


: ${PUBLIC_NET_NAME:="ext-net"}
: ${PUBLIC_SUBNET_NAME:="ext-subnet"}
: ${PUBLIC_IP_START:="10.80.1.0"}
: ${PUBLIC_IP_END:="10.95.255.254"}
: ${PUBLIC_GATEWAY:="10.80.0.1/12"}
: ${PUBLIC_IP_RANGE:="10.80.0.0/12"}

: ${ADMIN_ROUTER_NAME:="admin"}
: ${ADMIN_NET_NAME:="admin"}
: ${ADMIN_SUBNET_NAME:="admin"}
: ${ADMIN_IP_RANGE:="10.63.0.0/16"}
