FROM %%DOCKER_NAMESPACE%%/%%DOCKER_PREFIX%%openstack-base-alpine:%%DOCKER_TAG%%

ENV OPENSTACK_COMPONENT="keystone-api" \
    OS_COMP="keystone" \
    OS_REPO_URL="https://github.com/openstack/keystone.git"

COPY ./common-assets /opt/harbor/common-assets

COPY ./assets/ /opt/harbor/assets

RUN set -e && \
    set -x && \
    cp -rf /opt/harbor/common-assets/* / && \
    rm -rf /opt/harbor/common-assets && \
    cp -rf /opt/harbor/assets/* / && \
    rm -rf /opt/harbor/assets && \
    apk add --no-cache --virtual build-deps \
        gcc \
        git \
        musl-dev \
        python-dev \
        linux-headers \
        libffi-dev \
        postgresql-dev \
        openssl-dev \
        openldap-dev \
        libxml2-dev \
        libxslt-dev && \
    /opt/harbor/build/dockerfile.sh && \
    apk del build-deps
