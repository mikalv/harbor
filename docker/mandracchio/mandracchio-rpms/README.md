# port/mandracchio-rpms

## Function

This image serves as the rpm assets image for the Mandracchio build system, it contains the lunch scripts and helpers for the harbor platform, packed into an rpm.
It is consumed by the repo-builder. The assets that are installed on the Atomic host are held in the "./assets/payload" directory.

## Usage

The built image can be found @ the [Docker hub](https://hub.docker.com/r/port/mandracchio-base/). Or you can pull this image to a docker host by running:
```bash
docker pull port/mandracchio-rpms
```
