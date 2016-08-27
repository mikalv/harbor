FROM %%DOCKER_NAMESPACE%%/%%DOCKER_PREFIX%%openstack-glance-alpine:%%DOCKER_TAG%%

LABEL org.label-schema.name="%%DOCKER_FULLIMAGE%%" \
      org.label-schema.vcs-ref="%%DOCKER_TAG%%" \
      org.label-schema.build-date="%%DOCKER_BUILD_DATE%%"

ENV OPENSTACK_COMPONENT="glance-manager"

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
