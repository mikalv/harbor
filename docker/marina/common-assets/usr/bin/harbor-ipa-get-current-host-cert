#!/bin/bash
set -x
source /etc/os-container.env
export OS_DOMAIN=$(hostname -d)
source /etc/os-container.env
source /opt/harbor/harbor-common.sh
source /opt/harbor/service-hosts.sh
source /opt/harbor/freeipa-login-helper.sh
source /opt/harbor/marina/load-config-helper.sh
load_network_config


export OS_SERVICE=${MARINA_SERVICE}


get_current_host_certs () {
    SVC_AUTH_ROOT=$1
    SVC_NAME=$2
    mkdir -p ${SVC_AUTH_ROOT}
    HOST_SVC_KEY_LOC=${SVC_AUTH_ROOT}/${SVC_NAME}.key
    HOST_SVC_CRT_LOC=${SVC_AUTH_ROOT}/${SVC_NAME}.crt
    HOST_SVC_CA_LOC=${SVC_AUTH_ROOT}/${SVC_NAME}.crt

    until certutil -K -d /etc/ipa/nssdb -a -f /etc/ipa/nssdb/pwdfile.txt; do
       echo "Waiting for Certs"
       sleep 5
    done

    until pk12util -o /tmp/keys.p12 -n 'Local IPA host' -d /etc/ipa/nssdb -w /etc/ipa/nssdb/pwdfile.txt -k /etc/ipa/nssdb/pwdfile.txt; do
       echo "Waiting for Certs"
       sleep 5
    done

    openssl pkcs12 -in /tmp/keys.p12 -out ${HOST_SVC_KEY_LOC} -nocerts -nodes -passin file:/etc/ipa/nssdb/pwdfile.txt -passout pass:
    openssl pkcs12 -in /tmp/keys.p12 -out ${HOST_SVC_CRT_LOC} -clcerts -passin file:/etc/ipa/nssdb/pwdfile.txt -passout pass:
    openssl pkcs12 -in /tmp/keys.p12 -out ${HOST_SVC_CA_LOC} -cacerts -passin file:/etc/ipa/nssdb/pwdfile.txt -passout pass:
    rm -rf /tmp/keys.p12
}
check_required_vars MARINA_SERVICE HARBOR_SERVICE_DEFAULT_IP
get_current_host_certs /etc/harbor/marina/${MARINA_SERVICE} $(hostname -s)
