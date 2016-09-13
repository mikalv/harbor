FROM %%DOCKER_NAMESPACE%%/%%DOCKER_PREFIX%%openstack-base-fedora:%%DOCKER_TAG%%

ENV OPENSTACK_COMPONENT="keystone-api" \
    OS_COMP="keystone" \
    OS_REPO_URL="https://github.com/openstack/keystone.git"

RUN set -e && \
    set -x && \
    dnf install -y \
        ipsilon-client \
        openldap-clients \
        sssd-dbus \
        httpd \
        mod_ssl \
        mod_wsgi && \
    dnf clean all && \
    container-base-systemd-reset.sh

COPY ./common-assets /opt/harbor/common-assets

COPY ./assets/ /opt/harbor/assets

RUN set -e && \
    set -x && \
    rm -rf /etc/httpd/conf.d/*.conf && \
    cp -rf /opt/harbor/common-assets/* / && \
    rm -rf /opt/harbor/common-assets && \
    cp -rf /opt/harbor/assets/* / && \
    rm -rf /opt/harbor/assets && \
    dnf install -y \
        gcc \
        git \
        openssl-devel \
        python-devel \
        libffi-devel \
        openldap-devel \
        redhat-rpm-config && \
    /opt/harbor/build/dockerfile.sh && \
    dnf clean all && \
    container-base-systemd-reset.sh


RUN sed -i 's/^Listen 80/#Listen 80/' /etc/httpd/conf/httpd.conf

LABEL license="Apache-2.0" \
      vendor="Port Direct" \
      url="https://port.direct/" \
      vcs-type="Git" \
      vcs-url="https://github.com/portdirect/harbor" \
      name="%%DOCKER_FULLIMAGE%%" \
      vcs-ref="%%DOCKER_TAG%%" \
      build-date="%%DOCKER_BUILD_DATE%%"
