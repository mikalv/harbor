FROM %%DOCKER_NAMESPACE%%/%%DOCKER_PREFIX%%mandracchio-base:%%DOCKER_TAG%%
MAINTAINER Port Direct <support@port.direct>

RUN ( docker rm -f mandracchio-build-rpms || true ) && \
    docker run \
      -d \
      -p 172.17.0.1:81:80/tcp \
      --name mandracchio-build-rpms \
      port/mandracchio-rpms:latest

RUN ( docker rm -f mandracchio-build-repo || true ) && \
    docker run \
      -t \
      --name mandracchio-build-repo \
      --privileged \
      port/mandracchio-repo-assets:latest

RUN ( docker export mandracchio-build-repo > /tmp/mandracchio-build-repo.tar ) && \
    docker import /tmp/mandracchio-build-repo.tar port/mandracchio-repo:latest && \
    rm -f /tmp/mandracchio-build-repo.tar && \
    ( docker rm -f mandracchio-build-rpms || true )
