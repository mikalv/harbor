FROM alpine:latest
MAINTAINER Port Direct <support@port.direct>

ENV OS_DISTRO="HarborOS" \
    HARBOR_COMPONENT="kubernetes" \
    KUBE_COMPONENT="apiserver" \
    KUBE_LATEST_VERSION="v1.3.0"

LABEL license="Apache 2.0" \
      vendor="Harbor OpenStack"

RUN apk add --no-cache --virtual build-deps \
        ca-certificates \
        openssl \
        curl && \
    curl -L https://storage.googleapis.com/kubernetes-release/release/${KUBE_LATEST_VERSION}/bin/linux/amd64/kube-${KUBE_COMPONENT} > /usr/bin/kube-${KUBE_COMPONENT} && \
    chmod +x /usr/bin/kube-${KUBE_COMPONENT} && \
    apk del build-deps

ENTRYPOINT ["/usr/bin/kube-apiserver"]
