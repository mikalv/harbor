FROM %%DOCKER_NAMESPACE%%/%%DOCKER_PREFIX%%commissaire-base:%%DOCKER_TAG%%

COPY ./assets /opt/harbor/assets

RUN set -e && \
    set -x && \
    cp -rf /opt/harbor/assets/* / && \
    rm -rf /opt/harbor/assets
