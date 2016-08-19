FROM centos:latest
MAINTAINER Port Direct <support@port.direct>
LABEL license="Apache 2.0" \
      vendor="Harbor OpenStack"

ENV OS_DISTRO="HarborOS" \
    LC_ALL="en_US.UTF-8" \
    container=docker \
    OS_REPO_BRANCH="master" \
    HARBOR_COMPONENT="kubernetes" \
    KUBE_COMPONENT="kubelet" \
    KURYR_REPO="https://github.com/portdirect/kuryr.git" \
    KURYR_BRANCH="k8s" \
    KUBE_LATEST_VERSION="v1.3.0"

COPY ./common-assets /opt/harbor/common-assets

COPY ./assets/ /opt/harbor/assets

RUN cp -rf /opt/harbor/common-assets/* / && \
    rm -rf /opt/harbor/common-assets && \
    cp -rf /opt/harbor/assets/* / && \
    rm -rf /opt/harbor/assets && \
    yum install -y \
        epel-release \
        centos-release-gluster37 \
        centos-release-openstack-mitaka && \
    yum update -y && \
    yum upgrade -y && \
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
    curl -L https://storage.googleapis.com/kubernetes-release/release/${KUBE_LATEST_VERSION}/bin/linux/amd64/kubelet > /usr/bin/kubelet && \
    chmod +x /usr/bin/kubelet && \
    curl -L https://storage.googleapis.com/kubernetes-release/release/${KUBE_LATEST_VERSION}/bin/linux/amd64/kubectl > /usr/bin/kubectl && \
    chmod +x /usr/bin/kubectl && \
    yum install -y \
      git \
      gcc && \
    curl -s https://bootstrap.pypa.io/get-pip.py | python3 && \
    git clone --depth 1 ${KURYR_REPO} -b ${KURYR_BRANCH} /opt/kuryr  && \
    pip3 install /opt/kuryr && \
    yum history -y undo $(yum history list gcc | tail -2 | head -1 | awk '{ print $1}') && \
    yum clean all

# What a horrible hack. Whats going on here?
RUN /bin/cp -f /opt/kuryr/usr/libexec/kuryr/ovs /opt/kuryr/usr/libexec/kuryr/unbound

ADD ./assets /opt/harbor/assets
RUN cp -rf /opt/harbor/assets/* / && \
    mkdir -p /etc/kubernetes/manifests


CMD ["/kubelet"]
