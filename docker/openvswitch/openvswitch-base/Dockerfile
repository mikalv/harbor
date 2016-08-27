FROM %%DOCKER_NAMESPACE%%/%%DOCKER_PREFIX%%centos:%%DOCKER_TAG%%

LABEL org.label-schema.name="%%DOCKER_FULLIMAGE%%" \
      org.label-schema.vcs-ref="%%DOCKER_TAG%%" \
      org.label-schema.build-date="%%DOCKER_BUILD_DATE%%"

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
