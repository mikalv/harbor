FROM %%DOCKER_NAMESPACE%%/%%DOCKER_PREFIX%%openstack-base-alpine:%%DOCKER_TAG%%

LABEL org.label-schema.name="%%DOCKER_FULLIMAGE%%" \
      org.label-schema.vcs-ref="%%DOCKER_TAG%%" \
      org.label-schema.build-date="%%DOCKER_BUILD_DATE%%"

ADD ./assets /opt/harbor/assets

RUN set -e && \
    set -x && \
    /bin/cp -rf /opt/harbor/assets/* / && \
    /bin/rm -rf /opt/harbor/assets \ && \
    apk add --no-cache --virtual run-deps \
        pwgen


ENTRYPOINT ["/start.sh"]
