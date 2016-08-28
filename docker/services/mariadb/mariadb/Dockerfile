FROM %%DOCKER_NAMESPACE%%/%%DOCKER_PREFIX%%alpine:%%DOCKER_TAG%%

ENV HARBOR_COMPONENT="mariadb" \
    HARBOR_ETCD_COMPONENT="server"

COPY ./assets /opt/harbor/assets

RUN set -e && \
    set -x && \
    apk add --no-cache --virtual run-deps \
        mariadb \
        openssl && \
    cp -rf /opt/harbor/assets/* /

LABEL name="%%DOCKER_FULLIMAGE%%" \
      vcs-ref="%%DOCKER_TAG%%" \
      build-date="%%DOCKER_BUILD_DATE%%"
