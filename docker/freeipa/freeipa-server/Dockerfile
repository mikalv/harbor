FROM fedora:latest
MAINTAINER Port Direct <support@port.direct>

ENV OS_DISTRO="HarborOS" \
    HARBOR_COMPONENT="freeipa-server" \
    container=docker \
    OS_REPO_BRANCH="master"

LABEL license="Apache 2.0" \
      vendor="Harbor Ipsilon"


COPY ./assets/ /opt/harbor/assets
RUN cp -rf /opt/harbor/assets/* / && \
    rm -rf /opt/harbor/assets && \
    dnf install -y \
        'dnf-command(config-manager)' && \
    dnf config-manager --set-enabled updates-testing && \
    dnf update -y && \
    dnf upgrade -y && \
    dnf install -y \
        crudini \
        freeipa-server \
        freeipa-server-dns \
        bind \
        bind-dyndb-ldap && \
    dnf clean all

COPY ./common-assets /opt/harbor/common-assets
RUN cp -rf /opt/harbor/common-assets/* / && \
    rm -rf /opt/harbor/common-assets && \
    (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done); \
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
    cat /etc/systemd/system/systemd-hostnamed.service > /usr/lib/systemd/system/systemd-hostnamed.service && \
    ln -s /etc/systemd/system/dummy-service.service /etc/systemd/system/fedora-domainname.service && \
    systemctl set-default container-up.target && \
    systemctl enable container-configure-first.service


VOLUME [ "/sys/fs/cgroup" , "/run", "/tmp" , "/run/lock" , "/etc/os-config" ]

CMD ["/usr/sbin/init"]
