FROM %%DOCKER_NAMESPACE%%/%%DOCKER_PREFIX%%openstack-nova-alpine:%%DOCKER_TAG%%

ENV OPENSTACK_COMPONENT="nova-manager"

COPY ./assets/ /opt/harbor/assets

RUN set -e && \
    set -x && \
    apk add --no-cache --virtual build-deps \
        gcc \
        musl-dev \
        python-dev \
        linux-headers \
        openssl-dev && \
    mkdir -p /opt/stack && \
    pip --no-cache-dir install python-openstackclient && \
    apk del build-deps && \
    cp -rf /opt/harbor/assets/* / && \
    rm -rf /opt/harbor/assets

LABEL name="%%DOCKER_FULLIMAGE%%" \
      vcs-ref="%%DOCKER_TAG%%" \
      build-date="%%DOCKER_BUILD_DATE%%"
