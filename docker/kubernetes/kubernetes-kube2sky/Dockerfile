FROM gcr.io/google_containers/kube2sky:1.12
MAINTAINER Pete Birley <petebirley@gmail.com>
ENV OS_DISTRO HarborOS

LABEL org.label-schema.name="%%DOCKER_FULLIMAGE%%" \
      org.label-schema.vcs-ref="%%DOCKER_TAG%%" \
      org.label-schema.build-date="%%DOCKER_BUILD_DATE%%"

ADD ./assets /opt/harbor/assets

RUN set -e && \
    set -x && \
    cp -rf /opt/harbor/assets/* /

ENTRYPOINT ["/start.sh"]
