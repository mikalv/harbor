FROM %%DOCKER_NAMESPACE%%/%%DOCKER_PREFIX%%openstack-base-centos:%%DOCKER_TAG%%

ENV OPENSTACK_COMPONENT="keystone-api" \
    OS_COMP="keystone" \
    OS_REPO_URL="https://github.com/openstack/keystone.git"

RUN yum install -y \
        httpd \
        mod_ssl \
        mod_wsgi \
        mod_auth_mellon \
        ipsilon-client \
        openldap-clients \
        sssd-dbus && \
    yum clean all && \
    sed -i 's/^Listen 80/#Listen 80/' /etc/httpd/conf/httpd.conf && \
    yum install -y \
        gcc \
        git \
        openssl-devel \
        python-devel && \
    mkdir -p /opt/stack && \
    git clone ${OS_REPO_URL} -b ${OS_REPO_BRANCH} --depth 1 /opt/stack/${OS_COMP} && \
    pip --no-cache-dir install /opt/stack/${OS_COMP} && \
    mkdir -p /etc/${OS_COMP} && \
    cp -rf /opt/stack/${OS_COMP}/etc/* /etc/${OS_COMP}/ && \
    rm -rf /opt/stack/${OS_COMP} && \
    mkdir -p /var/log/${OS_COMP} && \
    mkdir -p /var/lib/${OS_COMP} && \
    mkdir -p /var/cache/${OS_COMP} && \
    groupadd ${OS_COMP} -g 1000 && \
    adduser -u 1000 -g ${OS_COMP} --system  ${OS_COMP} && \
    chown -R ${OS_COMP}:${OS_COMP} /var/log/${OS_COMP} && \
    chown -R ${OS_COMP}:${OS_COMP} /var/lib/${OS_COMP} && \
    chown -R ${OS_COMP}:${OS_COMP} /var/cache/${OS_COMP} && \
    yum history undo -y $(yum history package gcc | tail -2 | head -1 | awk '{print $1}') -y && \
    yum clean all

COPY ./common-assets /opt/harbor/common-assets
COPY ./assets/ /opt/harbor/assets
RUN cp -rf /opt/harbor/common-assets/* / && \
    rm -rf /opt/harbor/common-assets && \
    cp -rf /opt/harbor/assets/* / && \
    rm -rf /opt/harbor/assets
