FROM %%DOCKER_NAMESPACE%%/%%DOCKER_PREFIX%%openstack-base-alpine:%%DOCKER_TAG%%

ENV HARBOR_COMPONENT="marina"
COPY ./assets /opt/harbor/assets

RUN apk add --no-cache --virtual run-deps \
        docker \
        tar \
        gnupg && \
    apk add --no-cache --virtual build-deps \
        wget && \
    wget https://github.com/coreos/etcd/releases/download/${HARBOR_ETCD_RELEASE_VERSION}/etcd-${HARBOR_ETCD_RELEASE_VERSION}-linux-amd64.tar.gz && \
    tar xzvf etcd-${HARBOR_ETCD_RELEASE_VERSION}-linux-amd64.tar.gz && \
    mv etcd-${HARBOR_ETCD_RELEASE_VERSION}-linux-amd64/etcdctl /usr/bin/ && \
    curl -L https://storage.googleapis.com/kubernetes-release/release/${HARBOR_KUBE_RELEASE_VERSION}/bin/linux/amd64/kubectl > /usr/bin/kubectl && \
    chmod +x /usr/bin/kubectl && \
    apk del build-deps && \
    rm -Rf etcd-${HARBOR_ETCD_RELEASE_VERSION}-linux-amd64* && \
    cp -rf /opt/harbor/assets/* /

VOLUME ["/data"]
