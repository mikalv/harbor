FROM %%DOCKER_NAMESPACE%%/%%DOCKER_PREFIX%%openstack-base-fedora:%%DOCKER_TAG%%

LABEL org.label-schema.name="%%DOCKER_FULLIMAGE%%" \
      org.label-schema.vcs-ref="%%DOCKER_TAG%%" \
      org.label-schema.build-date="%%DOCKER_BUILD_DATE%%"

ENV OPENSTACK_COMPONENT="keystone-api" \
    OS_COMP="keystone" \
    OS_REPO_URL="https://github.com/openstack/keystone.git"

COPY ./common-assets /opt/harbor/common-assets

COPY ./assets/ /opt/harbor/assets

RUN set -e && \
    set -x && \
    cp -rf /opt/harbor/common-assets/* / && \
    rm -rf /opt/harbor/common-assets && \
    cp -rf /opt/harbor/assets/* / && \
    rm -rf /opt/harbor/assets && \
    dnf install -y \
        ipsilon-client \
        openldap-clients \
        sssd-dbus && \
    dnf install -y \
        gcc \
        git \
        openssl-devel \
        python-devel \
        redhat-rpm-config && \
    /opt/harbor/build/dockerfile.sh && \
    dnf clean all && \
    container-base-systemd-reset.sh

LABEL
