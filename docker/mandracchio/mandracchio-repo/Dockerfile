FROM centos:latest
MAINTAINER Port Direct <support@port.direct>

LABEL org.label-schema.name="%%DOCKER_FULLIMAGE%%" \
      org.label-schema.vcs-ref="%%DOCKER_TAG%%" \
      org.label-schema.build-date="%%DOCKER_BUILD_DATE%%"

ENV OS_DISTRO="HarborOS" \
    OPENSTACK_COMPONENT="mandracchio-repo" \
    LC_ALL="en_US.UTF-8" \
    container=docker \
    DOCKER_HOST="172.17.0.1:2375"

LABEL license="Apache 2.0" \
      vendor="Harbor OpenStack"

RUN set -e && \
    set -x && \
    yum update -y && \
    yum upgrade -y && \
    yum install -y \
        httpd \
        docker && \
    yum clean all

RUN set -e && \
    set -x && \
    ( docker rm -f mandracchio-build-rpms || true ) && \
    docker run \
      -d \
      -p 172.17.0.1:81:80/tcp \
      --name mandracchio-build-rpms \
      port/mandracchio-rpms:latest && \
    ( docker rm -f mandracchio-build-repo || true ) && \
    docker run \
      -t \
      --name mandracchio-build-repo \
      --privileged \
      port/mandracchio-repo-assets:latest /build.sh && \
    ( docker rm -f mandracchio-build-rpms || true ) && \
    docker cp mandracchio-build-repo:/srv/repo /srv && \
    ln -s /srv/repo/ /var/www/html/repo && \
    rm -f /etc/httpd/conf.d/welcome.conf && \
    mkdir -p /var/www/html/repo/images/pxeboot && \
    curl -L http://dl.fedoraproject.org/pub/alt/atomic/stable/Cloud_Atomic/x86_64/os/images/pxeboot/vmlinuz > /var/www/html/repo/images/pxeboot/vmlinuz && \
    curl -L http://dl.fedoraproject.org/pub/alt/atomic/stable/Cloud_Atomic/x86_64/os/images/pxeboot/initrd.img > /var/www/html/repo/images/pxeboot/initrd.img && \
    chown -R apache:apache /var/www/html/repo

ADD ./assets /opt/harbor/assets
RUN /bin/cp -rf /opt/harbor/assets/* /

CMD ["/start.sh"]
