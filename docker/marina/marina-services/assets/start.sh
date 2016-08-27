#!/bin/sh
source /etc/os-container.env

echo "$OS_DISTRO: Createing service cert"
/usr/bin/manage-harbor-service-cert.sh

if [ "$MARINA_SERVICE" = "kubernetes" ]; then
  echo "$OS_DISTRO: Service is Kubernetes, no action required"
else
  echo "$OS_DISTRO: Updating kube service"
  tail -f /dev/null
  /usr/bin/load-harbor-service.sh
fi

echo "$OS_DISTRO: Loaded Harbor Service"
shutdown -h now




rm -f /opt/harbor/kubernetes/templates/keystone/controllers.yaml && \
vi /opt/harbor/kubernetes/templates/keystone/controllers.yaml && \
(
prep_manifests ${LOAD_OS_SERVICE}

load_manifest ${LOAD_OS_SERVICE} namespace
load_manifest ${LOAD_OS_SERVICE} services
load_manifest ${LOAD_OS_SERVICE} secrets

load_manifest ${LOAD_OS_SERVICE} controllers
)

kube get pods
