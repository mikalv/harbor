FROM %%DOCKER_NAMESPACE%%/%%DOCKER_PREFIX%%openstack-base-centos:%%DOCKER_TAG%%

LABEL org.label-schema.name="%%DOCKER_FULLIMAGE%%" \
      org.label-schema.vcs-ref="%%DOCKER_TAG%%" \
      org.label-schema.build-date="%%DOCKER_BUILD_DATE%%"

ENV OPENSTACK_COMPONENT="base-httpd"

RUN set -e && \
    set -x && \
    yum install -y \
        httpd \
        mod_ssl \
        mod_wsgi && \
    yum clean all && \
    sed -i 's/^Listen 80/#Listen 80/' /etc/httpd/conf/httpd.conf && \
    container-base-systemd-reset.sh
