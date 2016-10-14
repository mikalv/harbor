FROM %%DOCKER_NAMESPACE%%/%%DOCKER_PREFIX%%centos:%%DOCKER_TAG%%

ENV HARBOR_COMPONENT="ovs" \
    HARBOR_SUBCOMPONENT="rpm-repo"

LABEL build-date="%%DOCKER_BUILD_DATE%%"

RUN set -e && \
    set -x && \
    yum install -y \
        git \
        kernel-lt \
        kernel-lt-devel \
        rpm-build \
        autoconf \
        automake \
        libtool \
        systemd-units \
        openssl \
        openssl-devel \
        python \
        python-twisted-core \
        python-zope-interface \
        python-six \
        desktop-file-utils \
        groff \
        graphviz \
        procps-ng \
        libcap-ng \
        libcap-ng-devel \
        dpdk-devel \
        selinux-policy-devel && \
    yum install -y \
        createrepo && \
    yum install -y \
        nginx && \
    yum clean all

ENV OS_COMP="ovs" \
    OS_REPO_URL="https://github.com/openvswitch/ovs.git" \
    OS_REPO_BRANCH="branch-2.6"

RUN set -e && \
    set -x && \
    KERNEL_VER=$(yum info kernel-lt | grep "^Version" | awk '{ print $NF }') && \
    KERNEL_REL=$(yum info kernel-lt | grep "^Release" | awk '{ print $NF }') && \
    KERNEL_ARCH=$(yum info kernel-lt | grep "^Arch" | awk '{ print $NF }') && \
    KERNEL_VERSION="${KERNEL_VER}-${KERNEL_REL}.${KERNEL_ARCH}" && \
    echo $KERNEL_VERSION && \
    git clone --depth 1 --branch ${OS_REPO_BRANCH} ${OS_REPO_URL} /opt/ovs-source && \
    cd /opt/ovs-source && \
      ./boot.sh && \
      ./configure --enable-ssl && \
      make rpm-fedora-kmod RPMBUILD_OPT="-D \"kversion ${KERNEL_VERSION}\"" && \
      make rpm-fedora RPMBUILD_OPT="--without check" && \
      make python/ovs/version.py && \
      mkdir -p /srv/python && \
      tar -cvf /srv/python/ovs.tar python/ && \
    cp -rf /opt/ovs-source/rpm/rpmbuild/RPMS/* /srv && \
    rm -rf /opt/ovs-source && \
    cd /srv && \
        createrepo . && \
    rm -rf /usr/share/nginx/html/* && \
    mv /srv/* /usr/share/nginx/html/

COPY ./assets /opt/harbor/assets

RUN set -e && \
    set -x && \
    /bin/cp -rf /opt/harbor/assets/* /

ENTRYPOINT []

CMD ["/start.sh"]

LABEL license="Apache-2.0" \
      vendor="Port Direct" \
      url="https://port.direct/" \
      vcs-type="Git" \
      vcs-url="https://github.com/portdirect/harbor" \
      name="%%DOCKER_FULLIMAGE%%" \
      vcs-ref="%%DOCKER_TAG%%" \
      build-date="%%DOCKER_BUILD_DATE%%"

# RUN yum install -y python-pip && \
#     pip --no-cache-dir install /srv/python/ovs.tar && \
#     yum install -y /srv/x86_64/*.rpm /srv/noarch/*.rpm && \
#     yum clean all && \
#     mkdir -p /var/run/openvswitch
