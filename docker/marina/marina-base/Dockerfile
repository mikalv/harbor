FROM %%DOCKER_NAMESPACE%%/%%DOCKER_PREFIX%%freeipa-client:%%DOCKER_TAG%%

ENV HARBOR_COMPONENT="marina"

RUN set -e && \
    set -x && \
    dnf install -y \
        docker-engine \
        tar \
        xz \
        pwgen && \
    dnf clean all && \
    curl -L https://github.com/coreos/etcd/releases/download/${HARBOR_ETCD_RELEASE_VERSION}/etcd-${HARBOR_ETCD_RELEASE_VERSION}-linux-amd64.tar.gz  > /tmp/etcd-${HARBOR_ETCD_RELEASE_VERSION}-linux-amd64.tar.gz && \
    cd /tmp && \
        tar xzvf etcd-${HARBOR_ETCD_RELEASE_VERSION}-linux-amd64.tar.gz && \
        cd / && \
    mv /tmp/etcd-${HARBOR_ETCD_RELEASE_VERSION}-linux-amd64/etcdctl /usr/bin/ && \
    curl -L https://storage.googleapis.com/kubernetes-release/release/${HARBOR_KUBE_RELEASE_VERSION}/bin/linux/amd64/kubectl > /usr/bin/kubectl && \
    chmod +x /usr/bin/kubectl && \
    rm -Rf /tmp/etcd-${HARBOR_ETCD_RELEASE_VERSION}-linux-amd64* && \
    container-base-systemd-reset.sh


COPY ./common-assets/ /opt/harbor/common-assets

RUN set -e && \
    set -x && \
    cp -rf /opt/harbor/common-assets/* / && \
    rm -rf /opt/harbor/common-assets

LABEL name="%%DOCKER_FULLIMAGE%%" \
      vcs-ref="%%DOCKER_TAG%%" \
      build-date="%%DOCKER_BUILD_DATE%%"
