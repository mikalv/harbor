FROM alpine:latest

MAINTAINER Port Direct <support@port.direct>

LABEL license="Apache 2.0" \
      vendor="Port Direct"

ENV OS_DISTRO="HarborOS-Alpine" \
    container=docker \
    OS_REPO_BRANCH="master" \
    HARBOR_ETCD_RELEASE_VERSION="v3.0.4" \
    HARBOR_KUBE_RELEASE_VERSION="v1.3.0"

COPY ./common-assets /opt/harbor/common-assets

RUN cp -rf /opt/harbor/common-assets/* / && \
    rm -rf /opt/harbor/common-assets && \
    apk upgrade --no-cache && \
    apk add --no-cache --virtual base-deps \
        findutils \
        curl

ENTRYPOINT ["/init"]
