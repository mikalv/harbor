FROM %%DOCKER_NAMESPACE%%/%%DOCKER_PREFIX%%mandracchio-base:%%DOCKER_TAG%%
MAINTAINER Port Direct <support@port.direct>

RUN ( docker rm -f mandracchio-build-rpms || true ) && \
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
    rm -f /etc/httpd/conf.d/welcome.conf

RUN mkdir -p /var/www/html/repo/images/pxeboot && \
    curl -L http://dl.fedoraproject.org/pub/alt/atomic/stable/Cloud_Atomic/x86_64/os/images/pxeboot/vmlinuz > /var/www/html/repo/images/pxeboot/vmlinuz && \
    curl -L http://dl.fedoraproject.org/pub/alt/atomic/stable/Cloud_Atomic/x86_64/os/images/pxeboot/initrd.img > /var/www/html/repo/images/pxeboot/initrd.img && \
    chown -R apache:apache /var/www/html/repo

ADD ./assets /opt/harbor/assets
RUN /bin/cp -rf /opt/harbor/assets/* /

CMD ["/start.sh"]
