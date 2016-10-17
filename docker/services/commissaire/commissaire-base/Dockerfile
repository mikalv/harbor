FROM %%DOCKER_NAMESPACE%%/%%DOCKER_PREFIX%%fedora:%%DOCKER_TAG%%

ENV HARBOR_COMPONENT="commissaire" \
    OS_COMP="commissaire" \
    OS_REPO_URL="https://github.com/projectatomic/commissaire.git" \
    OS_REPO_BRANCH="master" \
    OS_COMP_1="commissaire-service" \
    OS_REPO_URL_1="https://github.com/projectatomic/commissaire-service.git" \
    OS_REPO_BRANCH_1="master" \
    OS_COMP_2="commissaire-http" \
    OS_REPO_URL_2="https://github.com/projectatomic/commissaire-http.git" \
    OS_REPO_BRANCH_2="master" \
    OS_COMP_3="commctl" \
    OS_REPO_URL_3="https://github.com/projectatomic/commctl.git" \
    OS_REPO_BRANCH_3="master"

RUN set -e && \
    set -x && \
    dnf -y install --setopt=tsflags=nodocs \
        etcd \
        redis && \
    dnf -y install --setopt=tsflags=nodocs \
        python3 \
        python3-virtualenv && \
    dnf -y install --setopt=tsflags=nodocs \
        @development-tools \
        redhat-rpm-config && \
    dnf clean all

RUN set -e && \
    set -x && \
    mkdir /opt/stack && \
    git clone ${OS_REPO_URL} -b ${OS_REPO_BRANCH} --depth 1 /opt/stack/${OS_COMP} && \
    git clone ${OS_REPO_URL_1} -b ${OS_REPO_BRANCH_1} --depth 1 /opt/stack/${OS_COMP_1} && \
    git clone ${OS_REPO_URL_2} -b ${OS_REPO_BRANCH_2} --depth 1 /opt/stack/${OS_COMP_2} && \
    git clone ${OS_REPO_URL_3} -b ${OS_REPO_BRANCH_3} --depth 1 /opt/stack/${OS_COMP_3}

# https://github.com/projectatomic/commissaire-service/pull/8
RUN set -e && \
    set -x && \
    cd /opt/stack/${OS_COMP_1} && \
      git fetch origin pull/8/head:ansible

RUN set -e && \
    set -x && \
    cd /opt/stack/ && \
    virtualenv-3.5 devel && \
    . devel/bin/activate && \
    cd /opt/stack/${OS_COMP} && \
      pip3 install -e . && \
    cd /opt/stack/${OS_COMP_1} && \
      pip3 install -e . && \
    cd /opt/stack/${OS_COMP_2} && \
      pip3 install -e . && \
    cd /opt/stack/${OS_COMP_3} && \
      pip3 install -e .

COPY ./assets /opt/harbor/assets

RUN set -e && \
    set -x && \
    cp -rf /opt/harbor/assets/* / && \
    rm -rf /opt/harbor/assets
