FROM %%DOCKER_NAMESPACE%%/%%DOCKER_PREFIX%%centos:%%DOCKER_TAG%%

ENV HARBOR_COMPONENT="openvswitch-base"

COPY ./assets /opt/harbor/assets

RUN cp -rf /opt/harbor/assets/* / && \
    rm -rf /opt/harbor/assets && \
    yum install -y \
        openvswitch && \
    yum clean all

VOLUME ["/var/run/openvswitch"]

CMD ["/start.sh"]
