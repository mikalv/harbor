FROM centos:latest
MAINTAINER Port Direct <support@port.direct>

ENV OS_DISTRO="HarborOS" \
    OPENSTACK_COMPONENT="mandracchio-assets" \
    LC_ALL="en_US.UTF-8" \
    container=docker

LABEL license="Apache 2.0" \
      vendor="Harbor OpenStack"

ADD ./assets /opt/harbor/assets
RUN /bin/cp -rf /opt/harbor/assets/* / && \
    yum update -y && \
    yum upgrade -y && \
    yum install -y \
        rpm-ostree-toolbox && \
    yum clean all


ADD ./assets /opt/harbor/assets
RUN /bin/cp -rf /opt/harbor/assets/* / && \
    ostree --repo=/srv/repo init --mode=archive-z2

CMD ["/start.sh"]
