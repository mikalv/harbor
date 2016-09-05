# Harbor development

## Prerequisites

 * git
 * docker (>=v1.12)
 * kvm (if building host images)


## Builds / Release

To build the images in this repo requires docker to be listening on 172.17.0.1, this allows the post-process scripts for Mandracchio to run and also for some build-scripts to in turn run 'sub-builds' to reduce the final image size and remove the requirement for development tools like gcc et al. to be installed within the containers. SELinux should be set to a maximum enforcement level of 'Permissive' as otherwise some things can freak out (notably SElinux labeling inside a container)

The built images from this repository may be found at the Port.direct [docker hub](https://hub.docker.com/u/port/). Releases are split into two streams: 'latest' and 'stable'. 'Latest' builds for the Port.direct continuous release, while stable tracks the upstream OpenStack Release schedule and will only receive critical security updates following a release. It is strongly recommend that unless you have very specific requirements to use the the 'latest' release stream for the best experience.


### OpenvSwitch

Building containers that provide OpenvSwitch support require that a local OVS repo is running on the build host, this can be started with the following command:

```bash
docker run -d --name openvswitch-repo -p 172.17.0.1:80:80/tcp port/openvswitch-rpm:latest
```


### FreeIPA Server && Ipsilon-API

Building containers that provide the FreeIPA Server or Ipsilon API a local repo is running on the build host, this can be started with the following command:

```bash
docker run -d --name freeipa-repo -p 172.17.0.1:83:80/tcp port/freeipa-rpm:latest
```


### Ipsilon-API

Building containers that provide the Ipsilon API a local repo is running on the build host, this can be started with the following command:

```bash
docker run -d --name ipsilon-repo -p 172.17.0.1:82:80/tcp port/ipsilon-rpm:latest
```


### Quickstart
```bash
docker run -d --name openvswitch-repo -p 172.17.0.1:80:80/tcp port/openvswitch-rpm:latest
docker run -d --name freeipa-repo -p 172.17.0.1:83:80/tcp port/freeipa-rpm:latest
docker run -d --name ipsilon-repo -p 172.17.0.1:82:80/tcp port/ipsilon-rpm:latest
./tools/update-build-links
./tools/make-scripts-exec.sh
./tools/build-all-docker-images --release
```


### Cleaning up
```bash
docker rm -f freeipa-repo
docker rm -f ipsilon-repo
docker rm -f openvswitch-repo
```
