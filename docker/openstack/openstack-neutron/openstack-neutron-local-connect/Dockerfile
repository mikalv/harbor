FROM %%DOCKER_NAMESPACE%%/%%DOCKER_PREFIX%%openstack-neutron-client:%%DOCKER_TAG%%

COPY ./assets/ /opt/harbor/assets

RUN set -e && \
    set -x && \
    cp -rf /opt/harbor/assets/* / && \
    rm -rf /opt/harbor/assets && \
    echo "http://dl-cdn.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories && \
    curl -L https://raw.githubusercontent.com/jpetazzo/pipework/master/pipework > /usr/bin/pipework && \
    chmod +x /usr/bin/pipework && \
    apk add --no-cache --virtual run-deps  \
        util-linux \
        iptables \
        ip6tables \
        docker \
        iproute2

LABEL license="Apache-2.0" \
      vendor="Port Direct" \
      url="https://port.direct/" \
      vcs-type="Git" \
      vcs-url="https://github.com/portdirect/harbor" \
      name="%%DOCKER_FULLIMAGE%%" \
      vcs-ref="%%DOCKER_TAG%%" \
      build-date="%%DOCKER_BUILD_DATE%%"
