FROM %%DOCKER_NAMESPACE%%/%%DOCKER_PREFIX%%fedora:%%DOCKER_TAG%%

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
    container-base-systemd-reset.sh

ENTRYPOINT []

CMD ["/sbin/init"]
