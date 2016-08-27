FROM %%DOCKER_NAMESPACE%%/%%DOCKER_PREFIX%%fedora:%%DOCKER_TAG%%

LABEL org.label-schema.name="%%DOCKER_FULLIMAGE%%" \
      org.label-schema.vcs-ref="%%DOCKER_TAG%%" \
      org.label-schema.build-date="%%DOCKER_BUILD_DATE%%"

ENV HARBOR_COMPONENT="freeipa-client"

RUN set -e && \
    set -x && \
    dnf install -y \
        'dnf-command(config-manager)' && \
    dnf config-manager --set-enabled updates-testing && \
    dnf install -y \
        crudini \
        freeipa-client \
        freeipa-admintools && \
    dnf clean all && \
    container-base-systemd-reset.sh && \
    touch /init-ipa

ENTRYPOINT []

CMD ["/sbin/init"]
