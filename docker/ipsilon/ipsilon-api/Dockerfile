FROM fedora:latest
MAINTAINER Port Direct <support@port.direct>

ENV OS_DISTRO="HarborOS" \
    HARBOR_COMPONENT="ipsilon-api" \
    container=docker \
    OS_REPO_BRANCH="master"

LABEL license="Apache 2.0" \
      vendor="Harbor Ipsilon"

COPY ./common-assets /opt/harbor/common-assets
COPY ./assets/ /opt/harbor/assets
RUN cp -rf /opt/harbor/common-assets/* / && \
    rm -rf /opt/harbor/common-assets && \
    cp -rf /opt/harbor/assets/* / && \
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

RUN curl -L https://raw.githubusercontent.com/patternfly/patternfly/master/dist/css/patternfly.css > /usr/share/ipsilon/ui/css/patternfly.css && \
    curl -L https://raw.githubusercontent.com/patternfly/patternfly/master/dist/css/patternfly-additions.css > /usr/share/ipsilon/ui/css/patternfly-additions.css && \
    curl -L https://raw.githubusercontent.com/patternfly/patternfly/master/dist/fonts/OpenSans-Regular-webfont.woff > /usr/share/ipsilon/ui/fonts/OpenSans-Regular-webfont.woff && \
    curl -L https://raw.githubusercontent.com/patternfly/patternfly/master/dist/fonts/OpenSans-Semibold-webfont.woff > /usr/share/ipsilon/ui/fonts/OpenSans-Semibold-webfont.woff && \
    curl -L https://raw.githubusercontent.com/patternfly/patternfly/master/dist/fonts/OpenSans-Regular-webfont.ttf > /usr/share/ipsilon/ui/fonts/OpenSans-Regular-webfont.ttf && \
    curl -L https://raw.githubusercontent.com/patternfly/patternfly/master/dist/fonts/OpenSans-Semibold-webfont.ttf > /usr/share/ipsilon/ui/fonts/OpenSans-Semibold-webfont.ttf && \
    curl -L https://raw.githubusercontent.com/patternfly/patternfly/master/dist/img/bg-navbar-pf-alt.svg > /usr/share/ipsilon/ui/img/bg-navbar-pf-alt.svg

RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done); \
    rm -f /lib/systemd/system/multi-user.target.wants/*;\
    rm -f /etc/systemd/system/*.wants/*;\
    rm -f /lib/systemd/system/local-fs.target.wants/*; \
    rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
    rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
    rm -f /lib/systemd/system/basic.target.wants/*;\
    rm -f /lib/systemd/system/anaconda.target.wants/* && \
    rmdir -v /etc/systemd/system/multi-user.target.wants && \
    mkdir /etc/systemd/system/container-up.target.wants && \
    ln -s /etc/systemd/system/container-up.target.wants /etc/systemd/system/multi-user.target.wants && \
    systemctl set-default container-up.target && \
    systemctl enable container-configure-first.service

VOLUME [ "/sys/fs/cgroup" , "/run", "/tmp" , "/run/lock" ]

CMD ["/usr/sbin/init"]
