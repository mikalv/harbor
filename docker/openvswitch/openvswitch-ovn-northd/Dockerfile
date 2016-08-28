FROM %%DOCKER_NAMESPACE%%/%%DOCKER_PREFIX%%openvswitch-ovn-base:%%DOCKER_TAG%%

ENV HARBOR_COMPONENT="openvswitch-ovn-northd"

COPY ./assets /opt/harbor/assets

RUN set -e && \
    set -x && \
    cp -rf /opt/harbor/assets/* / && \
    rm -rf /opt/harbor/assets

LABEL name="%%DOCKER_FULLIMAGE%%" \
      vcs-ref="%%DOCKER_TAG%%" \
      build-date="%%DOCKER_BUILD_DATE%%"
