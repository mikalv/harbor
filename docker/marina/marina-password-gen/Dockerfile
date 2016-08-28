FROM %%DOCKER_NAMESPACE%%/%%DOCKER_PREFIX%%openstack-base-alpine:%%DOCKER_TAG%%

ADD ./assets /opt/harbor/assets

RUN set -e && \
    set -x && \
    /bin/cp -rf /opt/harbor/assets/* / && \
    /bin/rm -rf /opt/harbor/assets \ && \
    apk add --no-cache --virtual run-deps \
        pwgen

ENTRYPOINT ["/start.sh"]

LABEL name="%%DOCKER_FULLIMAGE%%" \
      vcs-ref="%%DOCKER_TAG%%" \
      build-date="%%DOCKER_BUILD_DATE%%"
