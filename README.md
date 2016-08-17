# Harbor

Harbor is the Kubernetes, Openstack, Atomic Linux and FreeIPA stack from port.direct.

Harbor pre-packages all of the open source components required to build a modern enterprise class container infrastructure, that easily integrates with your existing IT, and scales from a single laptop to the largest of data centers. Networking is provided by OVN from the [OpenvSwitch](https://github.com/openvswitch/ovs) project, improving both control and performance upon both the reference OpenStack and Kubernetes networking layers and allows seamless integration between the two platforms.

This repo contains the Dockerfiles and build scripts for the Harbor platform containers and RPM-OSTREE repository (Used by Mandracchio), the [Mandracchio](https://github.com/portdirect/mandracchio) repo contains the Build script for the linux host, the [Marina](https://github.com/portdirect/marina) repo contains deployment script and helpers, while the [Intermodal](https://github.com/portdirect/intermodal) repo contains standardized container images for use within Harbor.


## Builds / Release

To build the images in this rep requires docker to be listening (without tls!) on 172.17.0.1, this allows the post-process scripts for Mandracchio to run and also for some build-scripts to in turn run 'sub-builds' to reduce the final image size and remove the requirement for development tools like gcc et al. to be installed within the containers. SELinux should be set to a maximum enforcement level of 'Permissive' as otherwise some things can freak out (notably SElinux labeling inside a container)

The built images from this repository may be found at the Port.direct [docker hub](https://hub.docker.com/u/port/). Releases are split into two streams: 'latest' and 'stable'. 'Latest' builds for the Port.direct continuous release, while stable tracks the upstream OpenStack Release schedule and will only receive critical security updates following a release. It is strongly recommend that unless you have very specific requirements to use the the 'latest' release stream for the best experience.


### OpenvSwitch

Building containers that provide OpenvSwitch support require that a local OVS repo is running on the build host, this can be started with the following command:

```bash
docker run -d --name openvswitch-repo -p 172.17.0.1:80:80/tcp docker.io/port/openvswitch-rpm:latest
```
