
ipa-kra-install --password=password123


set -x
export OS_DOMAIN=$(hostname -d)
source /etc/os-container.env
source /opt/harbor/service-hosts.sh
source /opt/harbor/harbor-common.sh


OS_SERVICE=keystone-test
OS_SERVICE_IP=10.10.0.91
OS_SERVICE_TYPE=HTTP


OS_SERVICE_PHONE="8912847"
OS_SERVICE_LOCALITY="HarborOS"
OS_SERVICE_LOCATION="Region1"
OS_SERVICE_PLATFORM="Kubernetes"
OS_SERVICE_DESC="${OS_SERVICE_PLATFORM} ${OS_SERVICE_LOCALITY} ${OS_SERVICE^} service"

OS_SERVICE_CA_NAME="$(echo ${OS_SERVICE_LOCALITY}-${OS_SERVICE} | tr '[:upper:]' '[:lower:]' )"
OS_SERVICE_CA_CN="${OS_SERVICE_LOCALITY} ${OS_SERVICE^} CA"
OS_SERVICE_CA_ORG="$(echo ${OS_DOMAIN} | tr '[:lower:]' '[:upper:]' )"
OS_SERVICE_CA_DESC="${OS_SERVICE_PLATFORM} ${OS_SERVICE_LOCALITY} ${OS_SERVICE^} CA"


OS_SERVICE_VAULT_PASSWORD_FILE=/tmp/vault-password
echo "password123" > $OS_SERVICE_VAULT_PASSWORD_FILE

FREEIPA_HOST_ADMIN_USER=admin
echo ${FREEIPA_HOST_ADMIN_PASSWORD} | kinit ${FREEIPA_HOST_ADMIN_USER}


(ipa dnsrecord-show ${OS_DOMAIN} ${OS_SERVICE} --raw && (
IPA_SVC_IP=$(ipa dnsrecord-show ${OS_DOMAIN} ${OS_SERVICE} --raw | grep "arecord" | awk '{printf $NF}' | head -1)
if [ "${IPA_SVC_IP}" != "${OS_SERVICE_IP}" ]; then
  ipa dnsrecord-del ${OS_DOMAIN} ${OS_SERVICE} --del-all
  ipa dnsrecord-add ${OS_DOMAIN} ${OS_SERVICE} --a-rec=${OS_SERVICE_IP}
fi
)) || ipa dnsrecord-add ${OS_DOMAIN} ${OS_SERVICE} --a-rec=${OS_SERVICE_IP}

ipa host-show ${OS_SERVICE}.${OS_DOMAIN} || \
 /bin/sh -c "ipa host-add ${OS_SERVICE}.${OS_DOMAIN} --class=kubernetes_service \
 --locality=${OS_SERVICE_LOCALITY} \
 --location=${OS_SERVICE_LOCATION} \
 --platform=${OS_SERVICE_PLATFORM} \
 --desc='${OS_SERVICE_DESC}'"

ipa host-add-managedby ${OS_SERVICE}.${OS_DOMAIN} --hosts=$(hostname --fqdn) || true


ipa service-show ${OS_SERVICE_TYPE}/${OS_SERVICE}.${OS_DOMAIN} || ipa service-add ${OS_SERVICE_TYPE}/${OS_SERVICE}.${OS_DOMAIN}


ipa vault-show --service ${OS_SERVICE_TYPE}/${OS_SERVICE}.${OS_DOMAIN} ${OS_SERVICE} || \
ipa vault-add ${OS_SERVICE} --service ${OS_SERVICE_TYPE}/${OS_SERVICE}.${OS_DOMAIN} --type symmetric --password-file $OS_SERVICE_VAULT_PASSWORD_FILE


ipa ca-show ${OS_SERVICE_CA_NAME} || ipa ca-add ${OS_SERVICE_CA_NAME} --subject "CN=${OS_SERVICE_CA_CN}, O=${OS_SERVICE_CA_ORG}" --desc "${OS_SERVICE_CA_DESC}"

OS_SERVICE_DEFAULT_CA_ACL_NAME=${OS_SERVICE_CA_NAME}
OS_SERVICE_DEFAULT_CA_ACL_PROFILE=caIPAserviceCert
ipa caacl-show ${OS_SERVICE_DEFAULT_CA_ACL_NAME} || ipa caacl-add ${OS_SERVICE_DEFAULT_CA_ACL_NAME} --hostcat=all
ipa caacl-add-profile ${OS_SERVICE_DEFAULT_CA_ACL_NAME} --certprofile ${OS_SERVICE_DEFAULT_CA_ACL_PROFILE} || true
ipa caacl-add-ca ${OS_SERVICE_DEFAULT_CA_ACL_NAME} --ca ${OS_SERVICE_CA_NAME} || true



mkdir -p /data/certdb
echo "internal:mypassword" > /data/certdb/passwd.txt
chmod 600 /data/certdb/passwd.txt

certutil -N -d /data/certdb -f /data/certdb/passwd.txt
certutil -R -f /data/certdb/passwd.txt -s "CN=${OS_SERVICE}.${OS_DOMAIN}, O=${OS_SERVICE_CA_ORG}" -d /data/certdb -a > /tmp/${OS_SERVICE}.csr


ipa cert-request --principal ${OS_SERVICE_TYPE}/${OS_SERVICE}.${OS_DOMAIN} --ca ${OS_SERVICE_CA_NAME} /tmp/${OS_SERVICE}.csr


mkdir -p /data/working
ipa cert-show --ca ${OS_SERVICE_CA_NAME} 22 --out=/data/working/${OS_SERVICE}.crt
certutil -A -f /data/certdb/passwd.txt -d /data/certdb -n "Https-cert" -a -i /data/working/${OS_SERVICE}.crt -t ",,"





until certutil -K -d /data/certdb -a -f /data/certdb/passwd.txt; do
   echo "Waiting for Certs"
   sleep 5
done

until pk12util -o /tmp/keys.p12 -n 'Https-cert' -d /data/certdb -w /data/certdb/passwd.txt -k /data/certdb/passwd.txt; do
   echo "Waiting for Certs"
   sleep 5
done

HOST_SVC_LOC=/data/certs/${OS_SERVICE}
mkdir -p $HOST_SVC_LOC
HOST_SVC_KEY_LOC=${HOST_SVC_LOC}/cert.key
HOST_SVC_CRT_LOC=${HOST_SVC_LOC}/cert.crt
HOST_SVC_CA_LOC=${HOST_SVC_LOC}/ca.crt

openssl pkcs12 -in /tmp/keys.p12 -out ${HOST_SVC_KEY_LOC} -nocerts -nodes -passin file:/data/certdb/passwd.txt -passout pass:
openssl pkcs12 -in /tmp/keys.p12 -out ${HOST_SVC_CRT_LOC} -clcerts -passin file:/data/certdb/passwd.txt -passout pass:
openssl pkcs12 -in /tmp/keys.p12 -out ${HOST_SVC_CA_LOC} -cacerts -passin file:/data/certdb/passwd.txt -passout pass:





tar -zcvf ${OS_SERVICE}-certs.tar.gz /data

ipa vault-archive ${OS_SERVICE} \
  --service=${OS_SERVICE_TYPE}/${OS_SERVICE}.${OS_DOMAIN}
  --in=
  --password-file=$OS_SERVICE_VAULT_PASSWORD_FILE

++ printf '\033]0;%s@%s:%s\007' '' keystone-test /
[root@keystone-test /]#  --help


openssl x509 -in ${HOST_SVC_KEY_LOC} -text -noout
openssl x509 -in ${HOST_SVC_KEY_LOC} -inform der -text -noout

openssl x509 -in cert.cer -text -noout
openssl x509 -in cert.crt -text -noout
























certutil -R \
-p "$OS_SERVICE_PHONE" \
-n "${OS_SERVICE_CA_NAME} .${OS_DOMAIN}"  \
-s "CN=${OS_SERVICE_CA_NAME} .${OS_DOMAIN}" \
-d /etc/ipa/nssdb -o test.csr -g 4096 -a -f /etc/ipa/nssdb/pwdfile.txt  -z /dev/null




ipa cert-request \
  --principal ${OS_SERVICE_TYPE}/${OS_SERVICE}.${OS_DOMAIN} \
  --profile ${OS_SERVICE_DEFAULT_CA_ACL_PROFILE} \
  --ca ${OS_SERVICE_CA_NAME} /path/to/csr.req




ipa certprofile-show --out smime.cfg caIPAserviceCert
sed -i "s/profileId=caIPAserviceCert/c\profileId=KubeServicesServer/" smime.cfg
ipa certprofile-import KubeServicesServer --file smime.cfg \
  --desc "Kube Service certificates" --store TRUE


ipa hostgroup-add kubeservices --desc='Kubernetes Services'


OS_DOMAIN=$(hostname -d)
CA_NAME="KubeServices"
CA_CN="${CA_NAME} CA"
ORG="$(echo ${OS_DOMAIN}  | tr '[:lower:]' '[:upper:]')"



CAACL="caKubeServicesCert"
ipa caacl-add-ca ${CAACL} --ca ${CA_NAME}

ipa caacl-add \
--desc='Kube Serices Certs' \
caKubeServicesCert

ipa caacl-add-profile ${CAACL} --certprofiles=KubeServicesServer











test.svc.${OS_DOMAIN} --desc=\"kubernetes service endpoint\" --location=test.svc.${OS_DOMAIN}
ipa host-add-managedby ${OS_SERVICE}.${OS_DOMAIN} --hosts=\$(hostname --fqdn)
ipa service-add HTTP/test.svc.${OS_DOMAIN}

ipa cert-request  --ca sc --principal HTTP/test.svc.${OS_DOMAIN} --profile userSmartCard test.csr







OS_DOMAIN=novalocal
OS_SERVICE=test2.svc
OS_SERVICE_IP=172.18.12.3
OS_SERVICE_TYPE=HTTP

set -x
generate_service_cirt () {
  ################################################################################
  echo "${OS_DISTRO}: ${OPENSTACK_COMPONENT}: ${OPENSTACK_SUBCOMPONENT}: GENERATING SERVICE CIRT"
  ################################################################################

  #ipa service-add-host HTTP/${OS_SERVICE}.${OS_DOMAIN} --hosts=$(hostname --fqdn)
 docker exec ${FREEIPA_CONTAINER_NAME} mkdir -p ${SVC_AUTH_ROOT_IPA_CONTAINER}/${OS_SERVICE}
 certutil -R \
 -p "$OS_SERVICE_PHONE" \
 -n "${OS_SERVICE}.${OS_DOMAIN}"  \
 -s "CN=${OS_SERVICE}.${OS_DOMAIN}" \
 -8 "${OS_SERVICE}" \
 -d /etc/ipa/nssdb -o test.csr -g 4096 -a -f /etc/ipa/nssdb/pwdfile.txt  -z /dev/null

ipa cert-request  --ca sc --principal ${OS_SERVICE_TYPE}/${OS_SERVICE}.${OS_DOMAIN} test.csr
ipa cert-find --subject=${OS_SERVICE}.${OS_DOMAIN}
ipa cert-show --ca sc 12

 kdestroy
 sleep 30s
}
