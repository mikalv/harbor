FROM %%DOCKER_NAMESPACE%%/%%DOCKER_PREFIX%%openvswitch-base:%%DOCKER_TAG%%

LABEL org.label-schema.name="%%DOCKER_FULLIMAGE%%" \
      org.label-schema.vcs-ref="%%DOCKER_TAG%%" \
      org.label-schema.build-date="%%DOCKER_BUILD_DATE%%"

ENV HARBOR_COMPONENT="openvswitch-ovn-base"

RUN set -e && \
    set -x && \
    yum install -y \
        openvswitch-ovn-host && \
    yum clean all && \
    container-base-systemd-reset.sh
