FROM %%DOCKER_NAMESPACE%%/%%DOCKER_PREFIX%%ipsilon-client:%%DOCKER_TAG%%

ENV HARBOR_COMPONENT="freeipa-portal"

RUN set -e && \
    set -x && \
    dnf install -y \
        mod_wsgi \
        python-memcached \
        python-pillow \
        python-cherrypy \
        python-jinja2 \
        python-sqlalchemy \
        python-pip && \
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
