FROM fedora:latest

ENV HARBOR_COMPONENT="ipsilon" \
    OS_COMP="ipsilon" \
    OS_REPO_URL="https://github.com/portdirect/ipsilon.git" \
    OS_REPO_BRANCH="release-1.2"

RUN set -e && \
    set -x && \
    curl -L https://copr.fedorainfracloud.org/coprs/puiterwijk/Ipsilon-master-dependencies/repo/fedora-rawhide/puiterwijk-Ipsilon-master-dependencies-fedora-rawhide.repo > /etc/yum.repos.d/puiterwijk-Ipsilon-master-dependencies-fedora-24.repo && \
    dnf install -y \
        @development-tools \
        fedora-packager \
        rpmdevtools \
        python2-devel \
        git \
        which \
        findutils \
        sqlite \
        open-sans-fonts \
        make \
        pylint \
        python-pep8 \
        python-openid \
        python-openid-teams \
        python-openid-cla \
        python-cherrypy \
        m2crypto \
        lasso-python \
        python-sqlalchemy \
        python-ldap \
        python-pam \
        python-fedora \
        freeipa-python \
        httpd \
        mod_auth_mellon \
        postgresql-server \
        openssl mod_wsgi \
        python-jinja2 \
        python-psycopg2 \
        sssd \
        libsss_simpleifp \
        openldap-servers \
        mod_auth_gssapi \
        krb5-server \
        socket_wrapper \
        nss_wrapper \
        python-requests-kerberos \
        python-lesscpy \
        krb5-workstation \
        python-sssdconfig \
        mod_ssl \
        python-jwcrypto \
        httpd \
        mod_ssl \
        mod_wsgi \
        mod_auth_mellon \
        mod_auth_gssapi \
        mod_authnz_pam \
        mod_intercept_form_submit \
        mod_lookup_identity \
        openldap-clients \
        sssd-dbus \
        lasso \
        xmlsec1 \
        xmlsec1-openssl \
        mod_auth_openidc \
        createrepo \
        nginx \
        rubygems \
        gcc-c++ \
        ruby-devel && \
    dnf clean all && \
    gem install less && \
    gem install therubyracer && \
    useradd build && \
    mkdir -p /opt/stack && \
    chown -R build /opt/stack

USER build

WORKDIR /home/build


RUN set -e && \
    set -x && \
    git clone ${OS_REPO_URL} -b ${OS_REPO_BRANCH} --depth 1 /opt/stack/${OS_COMP}

RUN set -e && \
    set -x && \
    cd /opt/stack/${OS_COMP} && \
      make

RUN set -e && \
    set -x && \
    cd /opt/stack/${OS_COMP} && \
      make releaserpms

USER root

WORKDIR /

COPY ./assets/ /opt/harbor/assets

RUN set -e && \
    set -x && \
    cp /opt/stack/${OS_COMP}/dist/rpms/* /srv && \
    cd /srv && \
       createrepo . && \
    rm -rf /usr/share/nginx/html/* && \
    mv /srv/* /usr/share/nginx/html/ && \
    cp -rf /opt/harbor/assets/* / && \
    rm -rf /opt/harbor/assets

ENTRYPOINT []

CMD ["/start.sh"]

LABEL license="Apache-2.0" \
      vendor="Port Direct" \
      url="https://port.direct/" \
      vcs-type="Git" \
      vcs-url="https://github.com/portdirect/harbor" \
      name="%%DOCKER_FULLIMAGE%%" \
      vcs-ref="%%DOCKER_TAG%%" \
      build-date="%%DOCKER_BUILD_DATE%%"
