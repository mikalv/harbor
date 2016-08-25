#!/bin/sh
source /etc/os-container.env

echo "Createing service cert"
/usr/bin/manage-harbor-service-cert.sh

if [ "$MARINA_SERVICE" = "kubernetes" ]; then
  echo "Service is Kubernetes"
else
  echo "Updating kube service"
  /usr/bin/load-harbor-service.sh
fi

echo "Loaded Harbor Service"
shutdown -h now
