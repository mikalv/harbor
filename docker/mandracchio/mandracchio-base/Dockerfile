FROM centos:latest
MAINTAINER Port Direct <support@port.direct>

ENV OS_DISTRO="HarborOS" \
    OPENSTACK_COMPONENT="mandracchio-builder" \
    LC_ALL="en_US.UTF-8" \
    container=docker

LABEL license="Apache 2.0" \
      vendor="Harbor OpenStack"

ADD ./assets /opt/harbor/assets
RUN /bin/cp -rf /opt/harbor/assets/* / && \
    yum update -y && \
    yum upgrade -y && \
    yum install -y \
        rpm-ostree-toolbox \
        git \
        httpd \
        docker && \
    yum clean all

ENV DOCKER_HOST="172.17.0.1:2375"
