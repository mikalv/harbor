FROM alpine:latest
MAINTAINER Port Direct <support@port.direct>

ENV OS_DISTRO="HarborOS" \
    OPENSTACK_COMPONENT="base-alpine" \
    LC_ALL="en_US.UTF-8" \
    container=docker \
    OS_REPO_BRANCH="master"

LABEL license="Apache 2.0" \
      vendor="Harbor OpenStack"

COPY ./common-assets /opt/harbor/common-assets

RUN apk add --no-cache --virtual core-deps \
      python \
      sudo \
      curl && \
    chmod 0640 /etc/sudoers && \
    sed -i '/Defaults    requiretty/s/^/#/' /etc/sudoers && \
    chmod 0440 /etc/sudoers && \
    python -m ensurepip && \
    pip --no-cache-dir install --upgrade pip setuptools && \
    pip --no-cache-dir install crudini && \
    pip --no-cache-dir install PyMySQL && \
    pip --no-cache-dir install python-memcached && \
    cp -rf /opt/harbor/common-assets/* / && \
    rm -rf /opt/harbor/common-assets
