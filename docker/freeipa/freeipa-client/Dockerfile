FROM %%DOCKER_NAMESPACE%%/%%DOCKER_PREFIX%%fedora:%%DOCKER_TAG%%

ENV HARBOR_COMPONENT="freeipa-client"

COPY ./assets/ /opt/harbor/assets

RUN cp -rf /opt/harbor/assets/* / && \
    rm -rf /opt/harbor/assets && \
    dnf install -y \
        'dnf-command(config-manager)' && \
    dnf config-manager --set-enabled updates-testing && \
    dnf install -y \
        crudini \
        freeipa-client \
        freeipa-admintools && \
    dnf clean all
