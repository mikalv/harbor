FROM %%DOCKER_NAMESPACE%%/%%DOCKER_PREFIX%%openstack-base-alpine:%%DOCKER_TAG%%

LABEL org.label-schema.name="%%DOCKER_FULLIMAGE%%" \
      org.label-schema.vcs-ref="%%DOCKER_TAG%%" \
      org.label-schema.build-date="%%DOCKER_BUILD_DATE%%"

ENV OS_COMP="glance" \
    OS_REPO_URL="https://github.com/openstack/glance.git" \
    OS_REPO_BRANCH="master"

COPY ./common-assets /opt/harbor/common-assets

COPY ./assets/ /opt/harbor/assets

# Define compilers
ENV CC /usr/bin/clang
ENV CXX /usr/bin/clang++

# Alpine store some headers into /lib/
ENV LIBRARY_PATH=/lib:/usr/lib


RUN set -e && \
    set -x && \
    cp -rf /opt/harbor/common-assets/* / && \
    rm -rf /opt/harbor/common-assets && \
    cp -rf /opt/harbor/assets/* / && \
    rm -rf /opt/harbor/assets && \
    echo "http://dl-cdn.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories && \
    echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories && \
    apk add --no-cache --virtual run-deps  \
        py-xattr \
        libxml2 \
        libxslt \
        libldap \
        libsasl \
        libcurl \
        openssl && \
    apk add --no-cache --virtual build-deps \
        gcc \
        git \
        musl-dev \
        python-dev \
        linux-headers \
        libffi-dev \
        postgresql-dev \
        openssl-dev \
        libxml2-dev \
        libxslt-dev \
        curl \
        cmake \
        pkgconf \
        unzip \
        build-base \
        clang \
        clang-dev \
        zlib-dev \
        libtbb \
        libtbb-dev \
        linux-headers && \
    ln -s /usr/include/locale.h /usr/include/xlocale.h && \
    pip install cython && \
    pip install numpy && \
    /opt/harbor/build/dockerfile.sh && \
    apk del build-deps
