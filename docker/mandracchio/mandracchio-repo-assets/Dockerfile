FROM %%DOCKER_NAMESPACE%%/%%DOCKER_PREFIX%%mandracchio-base:%%DOCKER_TAG%%
MAINTAINER Port Direct <support@port.direct>

ADD ./assets /opt/harbor/assets
RUN /bin/cp -rf /opt/harbor/assets/* / && \
    ostree --repo=/srv/repo init --mode=archive-z2

CMD ["/start.sh"]
