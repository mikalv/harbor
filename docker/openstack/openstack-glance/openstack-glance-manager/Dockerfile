FROM %%DOCKER_NAMESPACE%%/%%DOCKER_PREFIX%%openstack-glance-alpine:%%DOCKER_TAG%%

ENV OPENSTACK_COMPONENT="glance-manager"

COPY ./assets/ /opt/harbor/assets

RUN set -e && \
    set -x && \
    cp -rf /opt/harbor/assets/* / && \
    rm -rf /opt/harbor/assets
