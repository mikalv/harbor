#!/bin/bash
: ${NEUTRON_MARIADB_SERVICE_PORT:="3308"}
: ${NEUTRON_DB_CA:="/run/harbor/auth/user/ca"}
: ${NEUTRON_DB_KEY:="/run/harbor/auth/user/key"}
: ${NEUTRON_DB_CERT:="/run/harbor/auth/user/crt"}
: ${NEUTRON_API_TLS_CA:="/run/harbor/auth/ssl/ca"}
: ${NEUTRON_API_TLS_KEY:="/run/harbor/auth/ssl/key"}
: ${NEUTRON_API_TLS_CERT:="/run/harbor/auth/ssl/crt"}
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

: ${OVN_L3_MODE:="False"}
: ${LBAAS_PROVIDER:="haproxy"}
