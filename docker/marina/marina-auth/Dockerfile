FROM %%DOCKER_NAMESPACE%%/%%DOCKER_PREFIX%%marina-base:%%DOCKER_TAG%%

LABEL license="Apache-2.0" \
      vendor="Port Direct" \
      url="https://port.direct/" \
      vcs-type="Git" \
      vcs-url="https://github.com/portdirect/harbor"

ADD ./assets /opt/harbor/assets

RUN set -e && \
    set -x && \
    /bin/cp -rf /opt/harbor/assets/* / && \
    /bin/rm -rf /opt/harbor/assets && \
    container-base-systemd-reset.sh

LABEL name="%%DOCKER_FULLIMAGE%%" \
      vcs-ref="%%DOCKER_TAG%%" \
      build-date="%%DOCKER_BUILD_DATE%%"
