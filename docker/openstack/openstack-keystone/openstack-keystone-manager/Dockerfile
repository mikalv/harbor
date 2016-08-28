FROM %%DOCKER_NAMESPACE%%/%%DOCKER_PREFIX%%openstack-keystone-api:%%DOCKER_TAG%%

ENV OPENSTACK_COMPONENT="keystone-manager"

COPY ./assets/ /opt/harbor/assets

RUN set -e && \
    set -x && \
    cp -rf /opt/harbor/assets/* / && \
    rm -rf /opt/harbor/assets

LABEL name="%%DOCKER_FULLIMAGE%%" \
      vcs-ref="%%DOCKER_TAG%%" \
      build-date="%%DOCKER_BUILD_DATE%%"
