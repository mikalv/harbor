FROM %%DOCKER_NAMESPACE%%/%%DOCKER_PREFIX%%openstack-base-httpd:%%DOCKER_TAG%%

LABEL org.label-schema.name="%%DOCKER_FULLIMAGE%%" \
      org.label-schema.vcs-ref="%%DOCKER_TAG%%" \
      org.label-schema.build-date="%%DOCKER_BUILD_DATE%%"

ENV OS_COMP="cinder" \
    OS_REPO_URL="https://github.com/openstack/cinder.git" \
    OS_REPO_BRANCH="master"

COPY ./common-assets /opt/harbor/common-assets

COPY ./assets/ /opt/harbor/assets

RUN set -e && \
    set -x && \
    cp -rf /opt/harbor/common-assets/* / && \
    rm -rf /opt/harbor/common-assets && \
    cp -rf /opt/harbor/assets/* / && \
    rm -rf /opt/harbor/assets && \
    yum install -y \
        iproute2 \
        libffi-devel \
        libxml2 \
        libxslt \
        lvm2 \
        parted \
        iscsi-initiator-utils \
        scsi-target-utils \
        targetcli && \
    sed -i "s|udev_rules = 1|udev_rules = 0|g" /etc/lvm/lvm.conf && \
    sed -i "s|udev_sync = 1|udev_sync = 0|g" /etc/lvm/lvm.conf && \
    yum install -y \
        mariadb \
        mariadb-libs && \
    yum install -y \
        gcc \
        git \
        kernel-lt \
        kernel-lt-headers \
        python-devel \
        libxml2-devel \
        libxslt-devel \
        postgresql-devel \
        openssl-devel && \
    yum clean all && \
    /opt/harbor/build/dockerfile.sh && \
    yum history undo -y $(yum history package gcc | tail -2 | head -1 | awk '{print $1}') -y && \
    yum clean all && \
    container-base-systemd-reset.sh
