FROM %%DOCKER_NAMESPACE%%/%%DOCKER_PREFIX%%openstack-base-centos:%%DOCKER_TAG%%

ENV OPENSTACK_COMPONENT="base-httpd"

RUN set -e && \
    set -x && \
    yum install -y \
        httpd \
        mod_ssl \
        mod_wsgi \
        mod_auth_mellon && \
    yum clean all && \
    sed -i 's/^Listen 80/#Listen 80/' /etc/httpd/conf/httpd.conf && \
    container-base-systemd-reset.sh
