FROM %%DOCKER_NAMESPACE%%/%%DOCKER_PREFIX%%openstack-base-centos:%%DOCKER_TAG%%

ENV OPENSTACK_COMPONENT="base-freeipa"

RUN yum install -y \
        ipa-admintools \
        ipa-client && \
    yum clean all
