FROM %%DOCKER_NAMESPACE%%/%%DOCKER_PREFIX%%fedora:%%DOCKER_TAG%%

ENV HARBOR_COMPONENT="ipsilon-api"

COPY ./assets/ /opt/harbor/assets

RUN cp -rf /opt/harbor/assets/* / && \
    rm -rf /opt/harbor/assets && \
    dnf update -y && \
    dnf upgrade -y && \
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
    dnf clean all

RUN container-base-systemd-reset.sh

VOLUME [ "/sys/fs/cgroup" , "/run", "/tmp" , "/run/lock" ]

CMD ["/usr/sbin/init"]

# RUN curl -L https://raw.githubusercontent.com/patternfly/patternfly/master/dist/css/patternfly.css > /usr/share/ipsilon/ui/css/patternfly.css && \
#     curl -L https://raw.githubusercontent.com/patternfly/patternfly/master/dist/css/patternfly-additions.css > /usr/share/ipsilon/ui/css/patternfly-additions.css && \
#     curl -L https://raw.githubusercontent.com/patternfly/patternfly/master/dist/fonts/OpenSans-Regular-webfont.woff > /usr/share/ipsilon/ui/fonts/OpenSans-Regular-webfont.woff && \
#     curl -L https://raw.githubusercontent.com/patternfly/patternfly/master/dist/fonts/OpenSans-Semibold-webfont.woff > /usr/share/ipsilon/ui/fonts/OpenSans-Semibold-webfont.woff && \
#     curl -L https://raw.githubusercontent.com/patternfly/patternfly/master/dist/fonts/OpenSans-Regular-webfont.ttf > /usr/share/ipsilon/ui/fonts/OpenSans-Regular-webfont.ttf && \
#     curl -L https://raw.githubusercontent.com/patternfly/patternfly/master/dist/fonts/OpenSans-Semibold-webfont.ttf > /usr/share/ipsilon/ui/fonts/OpenSans-Semibold-webfont.ttf && \
#     curl -L https://raw.githubusercontent.com/patternfly/patternfly/master/dist/img/bg-navbar-pf-alt.svg > /usr/share/ipsilon/ui/img/bg-navbar-pf-alt.svg
