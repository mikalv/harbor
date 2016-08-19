FROM centos:latest
MAINTAINER Port Direct <support@port.direct>

ENV OS_DISTRO="HarborOS" \
    HARBOR_COMPONENT="openvswitch-base" \
    LC_ALL="en_US.UTF-8" \
    container=docker \
    OS_REPO_BRANCH="master"

LABEL license="Apache 2.0" \
      vendor="Harbor OpenStack"

COPY ./common-assets /opt/harbor/common-assets
COPY ./assets /opt/harbor/assets
RUN cp -rf /opt/harbor/common-assets/* / && \
    rm -rf /opt/harbor/common-assets && \
    cp -rf /opt/harbor/assets/* / && \
    rm -rf /opt/harbor/assets && \
    yum install -y \
        epel-release && \
    yum update -y && \
    yum upgrade -y && \
    yum install -y \
        openvswitch && \
    yum clean all

VOLUME ["/var/run/openvswitch"]

CMD ["/start.sh"]
