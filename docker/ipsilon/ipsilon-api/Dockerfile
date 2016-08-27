FROM %%DOCKER_NAMESPACE%%/%%DOCKER_PREFIX%%freeipa-client:%%DOCKER_TAG%%

LABEL org.label-schema.name="%%DOCKER_FULLIMAGE%%" \
      org.label-schema.vcs-ref="%%DOCKER_TAG%%" \
      org.label-schema.build-date="%%DOCKER_BUILD_DATE%%"

ENV HARBOR_COMPONENT="ipsilon-api"

COPY ./assets/ /opt/harbor/assets

RUN set -e && \
    set -x && \
    cp -rf /opt/harbor/assets/* / && \
    rm -rf /opt/harbor/assets && \
    dnf install -y \
        'dnf-command(config-manager)' && \
    dnf config-manager --set-enabled updates-testing && \
    dnf install -y \
        findutils \
        postgresql \
        ipsilon \
        ipsilon-authfas \
        ipsilon-authform \
        ipsilon-authgssapi \
        ipsilon-authldap \
        ipsilon-authpam \
        ipsilon-base \
        ipsilon-client \
        ipsilon-filesystem \
        ipsilon-infosssd \
        ipsilon-openid \
        ipsilon-openidc \
        ipsilon-persona \
        ipsilon-saml2 \
        ipsilon-saml2-base \
        ipsilon-tools-ipa && \
    dnf clean all && \
    container-base-systemd-reset.sh




# RUN curl -L https://raw.githubusercontent.com/patternfly/patternfly/master/dist/css/patternfly.css > /usr/share/ipsilon/ui/css/patternfly.css && \
#     curl -L https://raw.githubusercontent.com/patternfly/patternfly/master/dist/css/patternfly-additions.css > /usr/share/ipsilon/ui/css/patternfly-additions.css && \
#     curl -L https://raw.githubusercontent.com/patternfly/patternfly/master/dist/fonts/OpenSans-Regular-webfont.woff > /usr/share/ipsilon/ui/fonts/OpenSans-Regular-webfont.woff && \
#     curl -L https://raw.githubusercontent.com/patternfly/patternfly/master/dist/fonts/OpenSans-Semibold-webfont.woff > /usr/share/ipsilon/ui/fonts/OpenSans-Semibold-webfont.woff && \
#     curl -L https://raw.githubusercontent.com/patternfly/patternfly/master/dist/fonts/OpenSans-Regular-webfont.ttf > /usr/share/ipsilon/ui/fonts/OpenSans-Regular-webfont.ttf && \
#     curl -L https://raw.githubusercontent.com/patternfly/patternfly/master/dist/fonts/OpenSans-Semibold-webfont.ttf > /usr/share/ipsilon/ui/fonts/OpenSans-Semibold-webfont.ttf && \
#     curl -L https://raw.githubusercontent.com/patternfly/patternfly/master/dist/img/bg-navbar-pf-alt.svg > /usr/share/ipsilon/ui/img/bg-navbar-pf-alt.svg
