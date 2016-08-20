FROM %%DOCKER_NAMESPACE%%/%%DOCKER_PREFIX%%fedora:%%DOCKER_TAG%%

ENV HARBOR_COMPONENT="freeipa-server"

RUN dnf install -y \
        'dnf-command(config-manager)' && \
    dnf config-manager --set-enabled updates-testing && \
    dnf install -y \
        crudini \
        freeipa-server \
        freeipa-server-dns \
        bind \
        bind-dyndb-ldap && \
    dnf clean all

RUN dnf install -y git && \
    git clone --depth 1 https://github.com/adelton/docker-freeipa.git /opt/docker-freeipa && \
    dnf clean all

COPY ./assets/ /opt/harbor/assets

RUN cd /opt/docker-freeipa && \
    find /etc/systemd/system/* '!' -name '*.wants' | xargs rm -rvf && \
    for i in basic.target network.service netconsole.service ; do rm -f /usr/lib/systemd/system/$i && ln -s /dev/null /usr/lib/systemd/system/$i ; done && \
    rm -fv /usr/lib/systemd/system/sysinit.target.wants/* && \
    echo 'disable *' > /usr/lib/systemd/system-preset/10-container-disable.preset && \
    echo LANG=C > /etc/locale.conf && \
    /sbin/ldconfig -X && \
    cp init-data ipa-server-configure-first ipa-server-status-check exit-with-status ipa-volume-upgrade-* /usr/sbin/ && \
    chmod -v +x /usr/sbin/init-data /usr/sbin/ipa-server-configure-first /usr/sbin/ipa-server-status-check /usr/sbin/exit-with-status /usr/sbin/ipa-volume-upgrade-* && \
    cp container-ipa.target ipa-server-configure-first.service ipa-server-upgrade.service ipa-server-update-self-ip-address.service kill-tail.service /usr/lib/systemd/system/ && \
    rm -rfv /etc/systemd/system/multi-user.target.wants && \
    mkdir /etc/systemd/system/container-ipa.target.wants && \
    ln -s /etc/systemd/system/container-ipa.target.wants /etc/systemd/system/multi-user.target.wants && \
    mkdir -p /usr/lib/systemd/system/shutdown.target.wants && ln -sf /usr/lib/systemd/system/kill-tail.service /usr/lib/systemd/system/shutdown.target.wants/kill-tail.service && \
    systemctl set-default container-ipa.target && \
    systemctl enable ipa-server-configure-first.service && \
    mkdir -p  /usr/lib/systemd/system/systemd-poweroff.service.d/ && \
    cp exit-via-chroot.conf /usr/lib/systemd/system/systemd-poweroff.service.d/ && \
    groupadd -g 288 kdcproxy ; useradd -u 288 -g 288 -c 'IPA KDC Proxy User' -d '/var/lib/kdcproxy' -s '/sbin/nologin' kdcproxy && \
    cp volume-data-list volume-data-mv-list volume-data-autoupdate /etc/ && \
    set -e ; cd / ; mkdir /data-template ; cat /etc/volume-data-list | while read i ; do echo $i ; if [ -e $i ] ; then tar cf - .$i | ( cd /data-template && tar xf - ) ; fi ; mkdir -p $( dirname $i ) ; if [ "$i" == /var/log/ ] ; then mv /var/log /var/log-removed ; else rm -rf $i ; fi ; ln -sf /data${i%/} ${i%/} ; done && \
    rm -rf /var/log-removed && \
    sed -i 's!^d /var/log.*!L /var/log - - - - /data/var/log!' /usr/lib/tmpfiles.d/var.conf && \
    mv /usr/lib/tmpfiles.d/journal-nocow.conf /usr/lib/tmpfiles.d/journal-nocow.conf.disabled && \
    mv /data-template/etc/dirsrv/schema /usr/share/dirsrv/schema && ln -s /usr/share/dirsrv/schema /data-template/etc/dirsrv/schema && \
    rm -f /data-template/var/lib/systemd/random-seed && \
    echo 1.1 > /etc/volume-version && \
    for i in /usr/lib/systemd/system/*-domainname.service ; do sed -i 's#^ExecStart=/#ExecStart=-/#' $i ; done && \
    uuidgen > /data-template/build-id

VOLUME [ "/sys/fs/cgroup" , "/run", "/tmp" , "/run/lock" , "/etc/os-config", "/data" ]

STOPSIGNAL RTMIN+3

ENTRYPOINT [ "/usr/sbin/init-data" ]
