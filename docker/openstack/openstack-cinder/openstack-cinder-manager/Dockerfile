FROM %%DOCKER_NAMESPACE%%/%%DOCKER_PREFIX%%openstack-cinder-alpine:%%DOCKER_TAG%%

ENV OPENSTACK_COMPONENT="cinder-manager"

COPY ./assets/ /opt/harbor/assets

RUN set -e && \
    set -x && \
    cp -rf /opt/harbor/assets/* / && \
    rm -rf /opt/harbor/assets
