FROM %%DOCKER_NAMESPACE%%/%%DOCKER_PREFIX%%centos:%%DOCKER_TAG%%

ENV HARBOR_COMPONENT="openvswitch-base"

COPY ./assets /opt/harbor/assets

RUN set -e && \
    set -x && \
    cp -rf /opt/harbor/assets/* / && \
    rm -rf /opt/harbor/assets && \
    yum install -y \
        openvswitch && \
    yum clean all && \
    container-base-systemd-reset.sh

VOLUME ["/var/run/openvswitch"]

ENTRYPOINT []
CMD ["/start.sh"]
