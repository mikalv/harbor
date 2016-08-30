FROM %%DOCKER_NAMESPACE%%/%%DOCKER_PREFIX%%alpine:%%DOCKER_TAG%%

ENV HARBOR_COMPONENT="rabbitmq" \
    RABBITMQ_VERSION=3.6.1

COPY ./assets /opt/harbor/assets

RUN set -e && \
    set -x && \
    apk add --no-cache --virtual run-deps \
        erlang \
        erlang-mnesia \
        erlang-public-key \
        erlang-crypto \
        erlang-ssl \
        erlang-sasl \
        erlang-asn1 \
        erlang-inets \
        erlang-os-mon \
        erlang-xmerl \
        erlang-eldap \
        erlang-syntax-tools && \
    apk add --no-cache --virtual build-deps \
        curl \
        tar \
        xz && \
    curl -sSL https://www.rabbitmq.com/releases/rabbitmq-server/v${RABBITMQ_VERSION}/rabbitmq-server-generic-unix-${RABBITMQ_VERSION}.tar.xz | tar -xJ -C / --strip-components 1 && \
    rm -rf /share/**/rabbitmq*.xz && \
    apk del build-deps && \
    addgroup rabbitmq && \
    adduser -DS -g "" -G rabbitmq -s /bin/sh -h /var/lib/rabbitmq rabbitmq && \
    mkdir -p /data/rabbitmq && \
    chown -R rabbitmq:rabbitmq /data/rabbitmq && \
    cp -rf /opt/harbor/assets/* /

LABEL license="Apache-2.0" \
      vendor="Port Direct" \
      url="https://port.direct/" \
      vcs-type="Git" \
      vcs-url="https://github.com/portdirect/harbor" \
      name="%%DOCKER_FULLIMAGE%%" \
      vcs-ref="%%DOCKER_TAG%%" \
      build-date="%%DOCKER_BUILD_DATE%%"
