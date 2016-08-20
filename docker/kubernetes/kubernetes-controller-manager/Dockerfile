FROM %%DOCKER_NAMESPACE%%/%%DOCKER_PREFIX%%alpine:%%DOCKER_TAG%%

ENV HARBOR_COMPONENT="kubernetes" \
    KUBE_COMPONENT="controller-manager"

RUN apk add --no-cache --virtual build-deps \
        ca-certificates \
        openssl \
        curl && \
    curl -L https://storage.googleapis.com/kubernetes-release/release/${HARBOR_KUBE_RELEASE_VERSION}/bin/linux/amd64/kube-${KUBE_COMPONENT} > /usr/bin/kube-${KUBE_COMPONENT} && \
    chmod +x /usr/bin/kube-${KUBE_COMPONENT} && \
    apk del build-deps

ENTRYPOINT ["/usr/bin/kube-controller-manager"]
