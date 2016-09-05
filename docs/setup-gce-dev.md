# Harbor GCE development

## Prerequisites

 * docker (>=v1.12)

 or

 * bash, awscli and jq

## Uploading development image

Uploading an image to AWS for development can be achived by running the script contained within the [mandracchio-image-aws](https://github.com/portdirect/harbor/blob/latest/docker/mandracchio/mandracchio-image-aws/) docker container, it can either be obtained from [here](https://github.com/portdirect/harbor/blob/latest/docker/mandracchio/mandracchio-image-aws/assets/upload.sh) and run manually, or you can run the script from the container by running:

```bash
sudo docker run \
  -it \
  --rm \
  -v $HOME/.aws:/root/.aws:rw \
  --entrypoint /bin/bash \
  docker.io/port/mandracchio-image-aws:latest /upload.sh
```

## Development environment access

Once the hosts is online you can connect via ssh with the username ```harbor```.
The following ports are required for interconnectivity between nodes:

 * 22/tcp <-- SSH
 * 443/tcp <-- All apis and Web UI
 * 80/tcp <-- Insecure HTTP assets
 * 9090/tcp <-- Management Console
 * 4001/tcp <-- Public(insecure) etcd
 * 6640/tcp <-- OpenvSwitch db(s)
 * 6642/tcp <-- OVN Southbound db
 * 6081/udp <-- Geneve

By default the master node will store the access credentials automcaticly generated during the node setup for the IPA server at ```/etc/harbor/harbor-auth.conf``` this file should **not** be left on the node for a production deployment once the environment has been bootstrapped.

Harbor makes extensive use of SNI for external access, all http access requires your dns to resolve the following domains to your instances ip(s) where ```${DOMAIN}``` should be replaced with the appropriate domain.

```
freeipa.${DOMAIN}
ipsilon.${DOMAIN}
keystone.${DOMAIN}
api.${DOMAIN}
```


## Booting development environment

Once you have uploaded the image, it can be booted via the aws management console. Once it has booted then login and run ``` sudo systemctl start kubelet ```, all the basic harbor services will then be automcaticly configured and started.

Alertnaticly a 3 node cluster can be booted with the docker container or [helper-script](https://github.com/portdirect/harbor/blob/latest/docker/mandracchio/mandracchio-image-aws/assets/boot.sh):

```bash
sudo docker run \
  -it \
  --rm \
  -v $HOME/.aws:/root/.aws:rw \
  --entrypoint /bin/bash \
  docker.io/port/mandracchio-image-aws:latest /boot.sh
```
