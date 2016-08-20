FROM %%DOCKER_NAMESPACE%%/%%DOCKER_PREFIX%%openvswitch-base:%%DOCKER_TAG%%

ENV HARBOR_COMPONENT="openvswitch-ovn-base"

RUN yum install -y \
        openvswitch-ovn-host && \
    yum clean all && \
    container-base-systemd-reset.sh
