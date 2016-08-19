FROM %%DOCKER_NAMESPACE%%/%%DOCKER_PREFIX%%openvswitch-ovn-base:%%DOCKER_TAG%%

ENV HARBOR_COMPONENT="openvswitch-ovn-ovsdb-nb"

COPY ./assets /opt/harbor/assets

RUN cp -rf /opt/harbor/assets/* / && \
    rm -rf /opt/harbor/assets
