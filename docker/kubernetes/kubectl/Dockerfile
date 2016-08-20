FROM %%DOCKER_NAMESPACE%%/%%DOCKER_PREFIX%%alpine:%%DOCKER_TAG%%

ENV HARBOR_COMPONENT="kubernetes" \
    KUBE_COMPONENT="kubectl"

RUN apk add --no-cache --virtual build-deps \
        ca-certificates \
        openssl \
        curl && \
    curl -L https://storage.googleapis.com/kubernetes-release/release/${HARBOR_KUBE_RELEASE_VERSION}/bin/linux/amd64/${KUBE_COMPONENT} > /usr/bin/${KUBE_COMPONENT} && \
    chmod +x /usr/bin/${KUBE_COMPONENT} && \
    apk del build-deps

ENTRYPOINT ["/usr/bin/kubectl"]
