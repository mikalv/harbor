FROM %%DOCKER_NAMESPACE%%/%%DOCKER_PREFIX%%openvswitch-base:%%DOCKER_TAG%%

ENV HARBOR_COMPONENT="openvswitch-vswitchd"

COPY ./assets /opt/harbor/assets

RUN cp -rf /opt/harbor/assets/* / && \
    rm -rf /opt/harbor/assets
