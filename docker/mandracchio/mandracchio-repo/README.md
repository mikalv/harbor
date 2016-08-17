# port/mandracchio-repo

## Function

This image both builds and servers the RPM-OSTREE repo for the Atomic Linux host image.

It also serves the latest (at the time of building) Fedora Atomic Host PXE installer images: these have proven better
than the CentOS installer at dealing with diverse hardware configs.

## Usage

The built image can be found @ the [Docker hub](https://hub.docker.com/r/port/mandracchio-repo/). Or you can pull this image to a docker host by running:
```bash
docker pull port/mandracchio-repo
```
