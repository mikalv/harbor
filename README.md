<p align="center">
  <img src="https://raw.githubusercontent.com/portdirect/Font-Awesome-SVG-PNG/master/black/png/256/ship.png" alt="Harbor"/>
</p>
# Harbor

Harbor is the Kubernetes, Openstack, Atomic Linux and FreeIPA stack from port.direct.

Harbor pre-packages all of the open source components required to build a modern enterprise class container infrastructure, that easily integrates with your existing IT, and scales from a single laptop to the largest of data centers. Networking is provided by OVN from the [OpenvSwitch](https://github.com/openvswitch/ovs) project, improving both control and performance upon both the reference OpenStack and Kubernetes networking layers and allows seamless integration between the two platforms.

This repo contains the Dockerfiles and build scripts for the Harbor platform containers and RPM-OSTREE repository (Used by Mandracchio), the [Mandracchio](https://github.com/portdirect/mandracchio) repo contains the Build script for the linux host, the [Marina](https://github.com/portdirect/marina) repo contains deployment script and helpers, while the [Intermodal](https://github.com/portdirect/intermodal) repo contains standardized container images for use within Harbor.
