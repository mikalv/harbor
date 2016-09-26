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
    dnf install -y \
        git && \
    git clone --depth 1 https://github.com/portdirect/ipa-portal.git /opt/portal && \
    git clone --depth 1 --branch master-dist https://github.com/patternfly/patternfly.git /opt/patternfly && \
    mkdir -p /opt/portal/freeipa_community_portal/assets && \
    mv /opt/patternfly/dist/* /opt/portal/freeipa_community_portal/assets && \
    rm -rf /opt/portal/freeipa_community_portal/assets/tests && \
    cp -rf /opt/portal/freeipa_community_portal/custom/* /opt/portal/freeipa_community_portal/assets/ && \
    pip --no-cache-dir install /opt/portal && \
    /usr/bin/freeipa-portal-install && \
    dnf clean all && \
    sed -i 's/^Listen 80/#Listen 80/' /etc/httpd/conf/httpd.conf && \
    sed -i 's/^Listen 443/#Listen 443/' /etc/httpd/conf.d/ssl.conf && \
    container-base-systemd-reset.sh

ENTRYPOINT []

CMD ["/usr/sbin/init-systemd-env"]

COPY ./assets/ /opt/harbor/assets

RUN set -e && \
    set -x && \
    mv /bin/hostnamectl /bin/hostnamectl-real && \
    cp -rf /opt/harbor/assets/* / && \
    rm -rf /opt/harbor/assets

LABEL license="Apache-2.0" \
      vendor="Port Direct" \
      url="https://port.direct/" \
      vcs-type="Git" \
      vcs-url="https://github.com/portdirect/harbor" \
      name="%%DOCKER_FULLIMAGE%%" \
      vcs-ref="%%DOCKER_TAG%%" \
      build-date="%%DOCKER_BUILD_DATE%%"
