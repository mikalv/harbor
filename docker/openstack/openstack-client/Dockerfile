FROM %%DOCKER_NAMESPACE%%/%%DOCKER_PREFIX%%openstack-base-alpine:%%DOCKER_TAG%%

ENV OS_COMP="openstackclient" \
    OS_CLIENT="openstack"

ADD ./assets /opt/harbor/assets

RUN apk add --no-cache --virtual build-deps \
        gcc \
        musl-dev \
        python-dev \
        linux-headers \
        openssl-dev && \
    mkdir -p /opt/stack && \
    pip install pbr && \
    pip install python-${OS_COMP} && \
    apk del build-deps && \
    mkdir -p /var/log/${OS_COMP} && \
    addgroup ${OS_COMP} -g 1000 && \
    adduser -u 1000 -D -s /bin/false -G ${OS_COMP} ${OS_COMP} && \
    chown -R ${OS_COMP}:${OS_COMP} /var/log/${OS_COMP} && \
    cp -rf /opt/harbor/assets/* / && \
    rm -rf /opt/harbor/assets

USER openstack
