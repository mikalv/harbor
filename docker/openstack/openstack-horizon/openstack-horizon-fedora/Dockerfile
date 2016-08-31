FROM %%DOCKER_NAMESPACE%%/%%DOCKER_PREFIX%%openstack-base-httpd:%%DOCKER_TAG%%

ENV OS_COMP="horizon" \
    OS_REPO_URL="https://github.com/portdirect/horizon.git" \
    OS_REPO_BRANCH="master" \
    OS_COMP_1="neutron-lbaas-dashboard" \
    OS_REPO_URL_1="https://github.com/openstack/neutron-lbaas-dashboard.git" \
    OS_REPO_BRANCH_1="master"


ADD ./common-assets/opt/harbor/build/dockerfile.sh /opt/harbor/build/dockerfile.sh

RUN set -e && \
    set -x && \
    apk add --no-cache --virtual run-deps \
        apache2 && \
    apk add --no-cache --virtual build-deps \
        gcc \
        git \
        musl-dev \
        python-dev \
        linux-headers \
        libffi-dev \
        postgresql-dev \
        openssl-dev && \
    /opt/harbor/build/dockerfile.sh && \
    apk del build-deps

ADD ./common-assets /opt/harbor/common-assets

RUN set -e && \
    set -x && \
    cp -rf /opt/harbor/common-assets/* / && \
    rm -rf /opt/harbor/common-assets && \
    HORIZON_CFG_FILE="/opt/stack/horizon/openstack_dashboard/local/local_settings.py" && \
    cp -f ${HORIZON_CFG_FILE}.build ${HORIZON_CFG_FILE} && \
    /opt/stack/horizon/manage.py collectstatic --noinput && \
    /opt/stack/horizon/manage.py compress && \
    rm -rf ${HORIZON_CFG_FILE}

LABEL license="Apache-2.0" \
      vendor="Port Direct" \
      url="https://port.direct/" \
      vcs-type="Git" \
      vcs-url="https://github.com/portdirect/harbor" \
      name="%%DOCKER_FULLIMAGE%%" \
      vcs-ref="%%DOCKER_TAG%%" \
      build-date="%%DOCKER_BUILD_DATE%%"
