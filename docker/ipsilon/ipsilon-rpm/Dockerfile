FROM %%DOCKER_NAMESPACE%%/%%DOCKER_PREFIX%%fedora:%%DOCKER_TAG%%

LABEL org.label-schema.name="%%DOCKER_FULLIMAGE%%" \
      org.label-schema.vcs-ref="%%DOCKER_TAG%%" \
      org.label-schema.build-date="%%DOCKER_BUILD_DATE%%"

ENV HARBOR_COMPONENT="ipsilon" \
    OS_COMP="ipsilon" \
    OS_REPO_URL="https://github.com/portdirect/ipsilon.git" \
    OS_REPO_BRANCH="master"

RUN set -e && \
    set -x && \
    dnf install -y \
        @development-tools \
        fedora-packager \
        rpmdevtools \
        python2-devel && \
    dnf install -y \
        git \
        which \
        findutils \
        sqlite \
        open-sans-fonts && \
    dnf install -y \
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
        python-jwcrypto && \
    dnf install -y \
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
        mod_auth_openidc && \
    dnf install -y \
        createrepo \
        nginx && \
    dnf clean all

RUN set -e && \
    set -x && \
    useradd build

RUN set -e && \
    set -x && \
    mkdir -p /opt/stack && \
    chown -R build /opt/stack

USER build

WORKDIR /home/build

RUN set -e && \
    set -x && \
    git clone ${OS_REPO_URL} -b ${OS_REPO_BRANCH} --depth 1 /opt/stack/${OS_COMP} && \
    cd /opt/stack/${OS_COMP} && \
      make && \
      make releaserpms

USER root

WORKDIR /

RUN set -e && \
    set -x && \
    cp /opt/stack/${OS_COMP}/dist/rpms/* /srv && \
    cd /srv && \
       createrepo . && \
    rm -rf /usr/share/nginx/html/* && \
    mv /srv/* /usr/share/nginx/html/

COPY ./assets/ /opt/harbor/assets

RUN set -e && \
    set -x && \
    cp -rf /opt/harbor/assets/* / && \
    rm -rf /opt/harbor/assets

ENTRYPOINT []

CMD ["/start.sh"]
