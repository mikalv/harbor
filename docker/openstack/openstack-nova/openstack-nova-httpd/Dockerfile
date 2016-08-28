FROM %%DOCKER_NAMESPACE%%/%%DOCKER_PREFIX%%openstack-base-httpd:%%DOCKER_TAG%%

ENV OS_COMP="nova" \
    OS_REPO_URL="https://github.com/openstack/nova.git" \
    OS_REPO_BRANCH="stable/mitaka" \
    OS_COMP_1="nova-docker" \
    OS_REPO_URL_1="https://github.com/portdirect/nova-docker.git" \
    OS_REPO_BRANCH_1="master"

COPY ./common-assets /opt/harbor/common-assets

COPY ./assets/ /opt/harbor/assets

RUN set -e && \
    set -x && \
    cp -rf /opt/harbor/common-assets/* / && \
    rm -rf /opt/harbor/common-assets && \
    cp -rf /opt/harbor/assets/* / && \
    rm -rf /opt/harbor/assets && \
    yum install -y \
        openvswitch \
        python-openvswitch \
        libxml2 \
        libxslt \
        openssl \
        libcurl \
        docker-engine \
        iproute \
        ethtool \
        openvswitch \
        sysfsutils \
        iscsi-initiator-utils \
        util-linux && \
    yum install -y \
        mariadb \
        mariadb-libs && \
    yum install -y \
        gcc \
        git \
        kernel-lt \
        kernel-lt-headers \
        python-devel \
        python-devel \
        postgresql-devel \
        openssl-devel \
        libxml2-devel \
        libxslt-devel && \
    yum clean all && \
    /opt/harbor/build/dockerfile.sh && \
    yum history undo -y $(yum history package gcc | tail -2 | head -1 | awk '{print $1}') -y && \
    yum clean all && \
    container-base-systemd-reset.sh

LABEL name="%%DOCKER_FULLIMAGE%%" \
      vcs-ref="%%DOCKER_TAG%%" \
      build-date="%%DOCKER_BUILD_DATE%%"
