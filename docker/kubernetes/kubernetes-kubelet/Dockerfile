FROM %%DOCKER_NAMESPACE%%/%%DOCKER_PREFIX%%centos:%%DOCKER_TAG%%

ENV LC_ALL="en_US.UTF-8" \
    HARBOR_COMPONENT="kubernetes" \
    KUBE_COMPONENT="kubelet" \
    KURYR_REPO="https://github.com/portdirect/kuryr.git" \
    KURYR_BRANCH="k8s" \
    HARBOR_KUBECTL_IMAGE="docker.io/port/kubectl:latest"

RUN set -e && \
    set -x && \
    yum install -y \
        openvswitch \
        python34 \
        python34-devel \
        sudo \
        ethtool \
        mariadb \
        jq \
        docker-engine && \
    chmod 0640 /etc/sudoers && \
    sed -i '/Defaults    requiretty/s/^/#/' /etc/sudoers && \
    chmod 0440 /etc/sudoers && \
    curl -L https://storage.googleapis.com/kubernetes-release/release/${HARBOR_KUBE_RELEASE_VERSION}/bin/linux/amd64/kubelet > /usr/bin/kubelet && \
    chmod +x /usr/bin/kubelet && \
    mkdir -p /etc/kubernetes/manifests && \
    yum install -y \
      git \
      gcc && \
    curl -s https://bootstrap.pypa.io/get-pip.py | python3 && \
    git clone --depth 1 ${KURYR_REPO} -b ${KURYR_BRANCH} /opt/kuryr  && \
    pip3 install /opt/kuryr && \
    yum history -y undo $(yum history list gcc | tail -2 | head -1 | awk '{ print $1}') && \
    yum clean all && \
    container-base-systemd-reset.sh

# What a horrible hack. Whats going on here?
RUN set -e && \
    set -x && \
    /bin/cp -f /opt/kuryr/usr/libexec/kuryr/ovs /opt/kuryr/usr/libexec/kuryr/unbound

ENTRYPOINT ["/kubelet"]

COPY ./assets/ /opt/harbor/assets

RUN set -e && \
    set -x && \
    cp -rf /opt/harbor/assets/* / && \
    rm -rf /opt/harbor/assets
