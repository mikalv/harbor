#!/bin/sh
source /etc/os-container.env

echo "$OS_DISTRO: Createing service cert"
/usr/bin/manage-harbor-service-cert.sh

if [ "$MARINA_SERVICE" = "kubernetes" ]; then
  echo "$OS_DISTRO: Service is Kubernetes, no action required"
else
  echo "$OS_DISTRO: Updating kube service"

fi

tail -f /dev/null
echo "$OS_DISTRO: Loaded Harbor Service"
shutdown -h now


rm -f /opt/harbor/kubernetes/templates/$MARINA_SERVICE/secrets.yaml && \
vi /opt/harbor/kubernetes/templates/$MARINA_SERVICE/secrets.yaml && \
  /usr/bin/load-harbor-service.sh

rm -f /opt/harbor/kubernetes/templates/$MARINA_SERVICE/controllers.yaml && \
vi /opt/harbor/kubernetes/templates/$MARINA_SERVICE/controllers.yaml && \
  /usr/bin/load-harbor-service.sh


rm -f /opt/harbor/kubernetes/templates/$MARINA_SERVICE/services.yaml && \
vi /opt/harbor/kubernetes/templates/$MARINA_SERVICE/services.yaml && \
/usr/bin/load-harbor-service.sh

prep_manifests ${LOAD_OS_SERVICE}

load_manifest ${LOAD_OS_SERVICE} namespace
load_manifest ${LOAD_OS_SERVICE} services
load_manifest ${LOAD_OS_SERVICE} secrets

load_manifest ${LOAD_OS_SERVICE} controllers
)

kube get pods
