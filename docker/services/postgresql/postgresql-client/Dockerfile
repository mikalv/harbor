FROM %%DOCKER_NAMESPACE%%/%%DOCKER_PREFIX%%alpine:%%DOCKER_TAG%%

ENV HARBOR_COMPONENT="mariadb" \
    HARBOR_ETCD_COMPONENT="client"

COPY ./assets /opt/harbor/assets

RUN set -e && \
    set -x && \
    apk add --no-cache --virtual run-deps \
        mariadb-client && \
    cp -rf /opt/harbor/assets/* /

CMD ["/start.sh"]
