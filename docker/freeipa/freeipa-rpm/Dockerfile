FROM fedora:latest

MAINTAINER Port Direct <support@port.direct>

LABEL license="Apache 2.0" \
      vendor="Port Direct"

ENV HARBOR_COMPONENT="freeipa" \
    OS_COMP="freeipa" \
    OS_REPO_URL="https://github.com/freeipa/freeipa.git" \
    OS_REPO_BRANCH="master"

COPY ./assets/ /opt/harbor/assets

RUN cp -rf /opt/harbor/assets/* / && \
    rm -rf /opt/harbor/assets

RUN dnf install -y \
        'dnf-command(config-manager)' && \
    dnf config-manager --set-enabled updates-testing && \
    dnf update -y && \
    dnf upgrade -y && \
    dnf install -y \
        @development-tools \
        fedora-packager \
        rpmdevtools \
        python2-devel && \
    dnf install -y \
        'dnf-command(builddep)' && \
    dnf install -y \
        createrepo \
        nginx && \
    dnf clean all

RUN mkdir -p /opt/stack && \
    git clone ${OS_REPO_URL} -b ${OS_REPO_BRANCH} --depth 1 /opt/stack/${OS_COMP} && \
    dnf install -y \
        java-1.8.0-openjdk-headless \
        krb5-libs && \
    cd /opt/stack/${OS_COMP} && \
      dnf builddep -y -b --spec freeipa.spec.in && \
    dnf clean all && \
    useradd build && \
    chown -R build /opt/stack

USER build

WORKDIR /home/build

RUN cd /opt/stack/${OS_COMP} && \
    make rpms

USER root

WORKDIR /

RUN cp /opt/stack/${OS_COMP}/dist/rpms/* /srv && \
    cd /srv && \
       createrepo . && \
    rm -rf /usr/share/nginx/html/* && \
    mv /srv/* /usr/share/nginx/html/

CMD ["/start.sh"]
