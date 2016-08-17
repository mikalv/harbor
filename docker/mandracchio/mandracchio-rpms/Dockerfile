FROM centos:latest
MAINTAINER Port Direct <support@port.direct>

ENV OS_DISTRO="HarborOS" \
    OPENSTACK_COMPONENT="mandracchio-rpm-repo" \
    LC_ALL="en_US.UTF-8" \
    container=docker

LABEL license="Apache 2.0" \
      vendor="Harbor OpenStack"

RUN yum install -y \
        epel-release && \
    yum update -y && \
    yum upgrade -y && \
    yum groupinstall -y \
        "Development Tools" && \
    yum install -y \
        openssl-devel \
        ncurses-devel \
        ncurses \
        bc \
        rpmdevtools \
        ruby-devel \
        gcc \
        make \
        git \
        rpm-build \
        httpd \
        createrepo \
        nginx  && \
    yum clean all && \
    rm -rf /usr/share/nginx/html/* && \
    gem install fpm && \
    mkdir -p /srv/repo/atomic-host/7/{SRPMS,i386,x86_64,noarch} && \
    chmod -R 0777 /srv/repo/atomic-host/7/{SRPMS,i386,x86_64,noarch} && \
    useradd user

ADD ./assets /opt/harbor/assets
RUN /bin/cp -rf /opt/harbor/assets/* /

RUN cd /tmp && \
    export PACKAGE_NAME="harbor-assets" && \
    export PACKAGE_VERSION="0.1" && \
    export PACKAGE_ARCH="x86_64" && \
    export PACKAGE_URL="https://port.direct" && \
    export ITERATIONS=$(date +%s) && \
    fpm \
      -s dir \
      -t rpm \
      --name $PACKAGE_NAME \
      --log info \
      --verbose \
      --version $PACKAGE_VERSION \
      --iteration $ITERATIONS \
      --architecture $PACKAGE_ARCH \
      --epoch 1 \
      --license "Apache 2.0" \
      --vendor "Harbor OpenStack" \
      --description "installation package for atomic hosts" \
      --url $PACKAGE_URL \
      --maintainer "Port Direct" \
    /payload && \
    cp $PACKAGE_NAME-$PACKAGE_VERSION-$ITERATIONS.$PACKAGE_ARCH.rpm /srv/repo/atomic-host/7/$PACKAGE_ARCH/ && \
    rm -rf /srv/repo/atomic-host/7/$PACKAGE_ARCH/repodata && \
    cd /srv/repo/atomic-host/7/$PACKAGE_ARCH && \
      createrepo . && \
    mv /srv/repo/atomic-host/7/$PACKAGE_ARCH/* /usr/share/nginx/html/

CMD ["/start.sh"]
