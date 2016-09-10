FROM %%DOCKER_NAMESPACE%%/%%DOCKER_PREFIX%%alpine:%%DOCKER_TAG%%

ENV OS_COMP="kuryr" \
    OS_REPO_URL="https://github.com/openstack/kuryr.git" \
    OS_REPO_BRANCH="master" \
    OS_COMP_1="kuryr-libnetwork" \
    OS_REPO_URL_1="https://github.com/openstack/kuryr-libnetwork.git" \
    OS_REPO_BRANCH_1="master"

COPY ./assets/ /opt/harbor/assets

RUN set -e && \
    set -x && \
    cp -rf /opt/harbor/assets/* / && \
    rm -rf /opt/harbor/assets && \
    apk add --no-cache --virtual run-deps \
        python \
        iproute2 \
        openvswitch \
        uwsgi-python && \
    apk add --no-cache --virtual build-deps \
        gcc \
        git \
        linux-headers \
        musl-dev \
        python-dev && \
    python -m ensurepip && \
    pip --no-cache-dir install --upgrade pip setuptools && \
    pip --no-cache-dir install crudini && \
    git clone -b ${OS_REPO_BRANCH} --depth 1 ${OS_REPO_URL} /opt/${OS_COMP} && \
    git clone -b ${OS_REPO_BRANCH_1} --depth 1 ${OS_REPO_URL_1} /opt/${OS_COMP_1} && \
    pip --no-cache-dir install /opt/${OS_COMP} && \
    cp -rf /opt/${OS_COMP}/usr /opt/${OS_COMP_1}/ && \
    cd /opt/${OS_COMP_1} && \
      python setup.py install  && \
    cd / && \
    rm -rf /opt/${OS_COMP} && \
    apk del build-deps



LABEL license="Apache-2.0" \
      vendor="Port Direct" \
      url="https://port.direct/" \
      vcs-type="Git" \
      vcs-url="https://github.com/portdirect/harbor" \
      name="%%DOCKER_FULLIMAGE%%" \
      vcs-ref="%%DOCKER_TAG%%" \
      build-date="%%DOCKER_BUILD_DATE%%"
