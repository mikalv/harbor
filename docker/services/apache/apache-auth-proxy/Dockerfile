FROM %%DOCKER_NAMESPACE%%/%%DOCKER_PREFIX%%ipsilon-client:%%DOCKER_TAG%%

ENV HARBOR_COMPONENT="apache-auth-proxy"


COPY ./assets/ /opt/harbor/assets

RUN set -e && \
    set -x && \
    cp -rf /opt/harbor/assets/* / && \
    rm -rf /opt/harbor/assets && \
    container-base-systemd-reset.sh

ENTRYPOINT ["/usr/sbin/init"]

CMD []
