FROM %%DOCKER_NAMESPACE%%/%%DOCKER_PREFIX%%fedora:%%DOCKER_TAG%%

ENV HARBOR_COMPONENT="freeipa-client"

RUN set -e && \
    set -x && \
    dnf install -y \
        'dnf-command(config-manager)' && \
    dnf config-manager --set-enabled updates-testing && \
    dnf install -y \
        crudini \
        hostname \
        freeipa-client && \
    dnf clean all && \
    container-base-systemd-reset.sh && \
    touch /init-ipa

ENTRYPOINT []

CMD ["/sbin/init"]

LABEL license="Apache-2.0" \
      vendor="Port Direct" \
      url="https://port.direct/" \
      vcs-type="Git" \
      vcs-url="https://github.com/portdirect/harbor" \
      name="%%DOCKER_FULLIMAGE%%" \
      vcs-ref="%%DOCKER_TAG%%" \
      build-date="%%DOCKER_BUILD_DATE%%"
