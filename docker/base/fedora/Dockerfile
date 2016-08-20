FROM fedora:latest

MAINTAINER Port Direct <support@port.direct>

LABEL license="Apache 2.0" \
      vendor="Port Direct"

ENV OS_DISTRO="HarborOS-Fedora" \
    container=docker \
    OS_REPO_BRANCH="master" \
    HARBOR_ETCD_RELEASE_VERSION="v3.0.4" \
    HARBOR_KUBE_RELEASE_VERSION="v1.3.0"

COPY ./common-assets /opt/harbor/common-assets

COPY ./assets/ /opt/harbor/assets

RUN cp -rf /opt/harbor/common-assets/* / && \
    rm -rf /opt/harbor/common-assets && \
    cp -rf /opt/harbor/assets/* / && \
    rm -rf /opt/harbor/assets && \
    dnf update -y && \
    dnf upgrade -y && \
    dnf install -y \
        findutils \
        iproute && \
    dnf clean all && \
    container-base-systemd-reset.sh

ENTRYPOINT ["/init"]
