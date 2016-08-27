FROM %%DOCKER_NAMESPACE%%/%%DOCKER_PREFIX%%marina-base:%%DOCKER_TAG%%

ADD ./assets /opt/harbor/assets

RUN set -e && \
    set -x && \
    /bin/cp -rf /opt/harbor/assets/* / && \
    /bin/rm -rf /opt/harbor/assets && \
    container-base-systemd-reset.sh && \
    rm -f /init-ipa

ENTRYPOINT ["/init"]
