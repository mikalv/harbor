FROM alpine:latest
MAINTAINER Port Direct <support@port.direct>

ENV OS_DISTRO="HarborOS" \
    HARBOR_COMPONENT="etcd" \
    LC_ALL="en_US.UTF-8" \
    container=docker \
    OS_REPO_BRANCH="master" \
    HARBOR_ETCD_RELEASE_VERSION="v3.0.4"

LABEL license="Apache 2.0" \
      vendor="Harbor OpenStack"

COPY ./common-assets /opt/harbor/common-assets
RUN cp -rf /opt/harbor/common-assets/* / && \
    rm -rf /opt/harbor/common-assets

VOLUME ["/data"]
CMD ["/start.sh"]
