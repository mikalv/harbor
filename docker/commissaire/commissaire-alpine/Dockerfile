FROM %%DOCKER_NAMESPACE%%/%%DOCKER_PREFIX%%alpine:%%DOCKER_TAG%%

ENV HARBOR_COMPONENT="commissaire" \
    OS_COMP="commissaire" \
    OS_REPO_URL="https://github.com/portdirect/commissaire.git" \
    OS_REPO_BRANCH="master" \
    OS_COMP_1="commissaire-service" \
    OS_REPO_URL_1="https://github.com/portdirect/commissaire-service.git" \
    OS_REPO_BRANCH_1="ansible" \
    OS_COMP_2="commissaire-http" \
    OS_REPO_URL_2="https://github.com/portdirect/commissaire-http.git" \
    OS_REPO_BRANCH_2="master" \
    OS_COMP_3="commctl" \
    OS_REPO_URL_3="https://github.com/projectatomic/commctl.git" \
    OS_REPO_BRANCH_3="master"


RUN set -e && \
    set -x && \
    apk add --no-cache --virtual run-deps \
        python3 && \
    apk add --no-cache --virtual build-deps \
        gcc \
        git \
        linux-headers \
        musl-dev \
        python3-dev \
        libffi-dev \
        openssl-dev && \
    python3 -m ensurepip && \
    pip3 --no-cache-dir install --upgrade pip setuptools && \
    pip3 --no-cache-dir install pyopenssl && \
    mkdir -p /opt/stack && \
    git clone ${OS_REPO_URL} -b ${OS_REPO_BRANCH} --depth 1 /opt/stack/${OS_COMP} && \
    git clone ${OS_REPO_URL_1} -b ${OS_REPO_BRANCH_1} --depth 1 /opt/stack/${OS_COMP_1} && \
    git clone ${OS_REPO_URL_2} -b ${OS_REPO_BRANCH_2} --depth 1 /opt/stack/${OS_COMP_2} && \
    git clone ${OS_REPO_URL_3} -b ${OS_REPO_BRANCH_3} --depth 1 /opt/stack/${OS_COMP_3} && \
    cd /opt/stack/${OS_COMP} && \
      pip3 install -e . && \
    cd /opt/stack/${OS_COMP_1} && \
      pip3 install -e . && \
    cd /opt/stack/${OS_COMP_2} && \
      pip3 install -e . && \
    cd /opt/stack/${OS_COMP_3} && \
      pip3 install -e . && \
    apk del build-deps

COPY ./common-assets /opt/harbor/common-assets

RUN set -e && \
    set -x && \
    cp -rf /opt/harbor/common-assets/* / && \
    rm -rf /opt/harbor/common-assets

LABEL license="Apache-2.0" \
      vendor="Port Direct" \
      url="https://port.direct/" \
      vcs-type="Git" \
      vcs-url="https://github.com/portdirect/harbor" \
      name="%%DOCKER_FULLIMAGE%%" \
      vcs-ref="%%DOCKER_TAG%%" \
      build-date="%%DOCKER_BUILD_DATE%%"
