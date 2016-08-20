FROM %%DOCKER_NAMESPACE%%/%%DOCKER_PREFIX%%alpine:%%DOCKER_TAG%%

ENV OPENSTACK_COMPONENT="base-alpine"

RUN apk add --no-cache --virtual core-deps \
      python \
      sudo \
      curl && \
    chmod 0640 /etc/sudoers && \
    sed -i '/Defaults    requiretty/s/^/#/' /etc/sudoers && \
    chmod 0440 /etc/sudoers && \
    python -m ensurepip && \
    pip --no-cache-dir install --upgrade pip setuptools && \
    pip --no-cache-dir install crudini && \
    pip --no-cache-dir install PyMySQL && \
    pip --no-cache-dir install python-memcached
