FROM gcr.io/google_containers/kube2sky:1.12
MAINTAINER Pete Birley <petebirley@gmail.com>
ENV OS_DISTRO HarborOS

ADD ./assets /opt/harbor/assets

RUN set -e && \
    set -x && \
    cp -rf /opt/harbor/assets/* /

ENTRYPOINT ["/start.sh"]
