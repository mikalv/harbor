FROM centos:latest
MAINTAINER Port Direct <support@port.direct>

ENV OS_DISTRO="HarborOS" \
    OPENSTACK_COMPONENT="ovs" \
    OPENSTACK_SUBCOMPONENT="rpm-repo" \
    LC_ALL="en_US.UTF-8" \
    container=docker

LABEL license="Apache 2.0" \
      vendor="Harbor OpenStack"

ADD ./assets/etc/yum.repos.d/elrepo-kernel.repo /etc/yum.repos.d/elrepo-kernel.repo

ENV KERNEL_VERSION=4.4.16-1.el7.elrepo.x86_64

RUN yum install -y \
        epel-release && \
    yum update -y && \
    yum upgrade -y && \
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
    yum clean all

ENV OS_COMP="ovs" \
    OS_REPO_URL="https://github.com/portdirect/ovs.git" \
    OS_REPO_BRANCH="master"

RUN git clone --depth 1 --branch ${OS_REPO_BRANCH} ${OS_REPO_URL} /opt/ovs-source && \
    cd /opt/ovs-source && \
      ./boot.sh && \
      ./configure --enable-ssl && \
      make rpm-fedora-kmod RPMBUILD_OPT='-D "kversion ${KERNEL_VERSION}"' && \
      make rpm-fedora RPMBUILD_OPT="--without check" && \
      make python/ovs/version.py && \
      mkdir -p /srv/python && \
      tar -cvf /srv/python/ovs.tar python/ && \
    cp -rf /opt/ovs-source/rpm/rpmbuild/RPMS/* /srv && \
    rm -rf /opt/ovs-source

RUN yum install -y \
        createrepo && \
    yum clean all && \
    cd /srv && \
        createrepo .

RUN yum install -y \
        nginx && \
    yum clean all && \
    rm -rf /usr/share/nginx/html/* && \
    mv /srv/* /usr/share/nginx/html/

ADD ./assets /opt/harbor/assets
RUN /bin/cp -rf /opt/harbor/assets/* /
CMD ["/start.sh"]

# RUN yum install -y python-pip && \
#     pip install /srv/python/ovs.tar && \
#     yum install -y /srv/x86_64/*.rpm /srv/noarch/*.rpm && \
#     yum clean all && \
#     mkdir -p /var/run/openvswitch
