FROM centos:latest
MAINTAINER Port Direct <support@port.direct>

ENV OS_DISTRO="HarborOS" \
    OPENSTACK_COMPONENT="base-centos" \
    LC_ALL="en_US.UTF-8" \
    container=docker

LABEL license="Apache 2.0" \
      vendor="Harbor OpenStack"

ADD ./common-assets /opt/harbor/common-assets
ADD ./assets/ /opt/harbor/assets
RUN cp -rf /opt/harbor/common-assets/* / && \
    rm -rf /opt/harbor/common-assets && \
    cp -rf /opt/harbor/assets/* / && \
    rm -rf /opt/harbor/assets && \
    yum install -y \
        epel-release \
        centos-release-gluster37 \
        centos-release-openstack-mitaka && \
    yum update -y && \
    yum install -y \
        python \
        sudo \
        curl \
        python-pip && \
    yum clean all && \
    chmod 0640 /etc/sudoers && \
    sed -i '/Defaults    requiretty/s/^/#/' /etc/sudoers && \
    chmod 0440 /etc/sudoers && \
    pip --no-cache-dir install --upgrade pip setuptools && \
    pip --no-cache-dir install crudini && \
    pip --no-cache-dir install PyMySQL && \
    pip --no-cache-dir install python-memcached
