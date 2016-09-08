#!/bin/bash

# Copyright 2016 Port Direct
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -e
echo "${OS_DISTRO}: Starting HAProxy Container"
################################################################################
source /opt/harbor/harbor-vars.sh
source /opt/harbor/service-hosts.sh
source /opt/harbor/harbor-common.sh
: ${HAPROXY_TLS_CA:="/run/harbor/auth/ssl/tls.ca"}
: ${HAPROXY_TLS_KEY:="/run/harbor/auth/ssl/tls.key"}
: ${HAPROXY_TLS_CERT:="/run/harbor/auth/ssl/tls.crt"}


################################################################################
check_required_vars OS_DOMAIN \
                    PORT_LOCAL \
                    PORT_EXPOSE \
                    MY_IP



echo "${OS_DISTRO}: Setting Up TLS"
################################################################################
mkdir -p /etc/haproxy/tls
cat ${HAPROXY_TLS_CERT} > /etc/haproxy/tls/local.pem
cat ${HAPROXY_TLS_KEY} >> /etc/haproxy/tls/local.pem


echo "${OS_DISTRO}: Writing Config"
################################################################################
cat > /etc/haproxy/haproxy.cfg <<EOF
#---------------------------------------------------------------------
# Global settings
#---------------------------------------------------------------------
global
    # to have these messages end up in /var/log/haproxy.log you will
    # need to:
    #
    # 1) configure syslog to accept network log events.  This is done
    #    by adding the '-r' option to the SYSLOGD_OPTIONS in
    #    /etc/sysconfig/syslog
    #
    # 2) configure local2 events to go to the /var/log/haproxy.log
    #   file. A line like the following can be added to
    #   /etc/sysconfig/syslog
    #
    #    local2.*                       /var/log/haproxy.log
    #
    log         127.0.0.1 local2 crit

    chroot      /var/lib/haproxy
    pidfile     /var/run/haproxy.pid
    maxconn     4000
    user        haproxy
    group       haproxy
    daemon

#---------------------------------------------------------------------
# common defaults that all the 'listen' and 'backend' sections will
# use if not designated in their block
#---------------------------------------------------------------------
defaults
    log                     global
    option                  dontlognull
    option http-server-close
    option                  redispatch
    retries                 3
    timeout http-request    10s
    timeout queue           1m
    timeout connect         10s
    timeout client          1m
    timeout server          1m
    timeout http-keep-alive 10s
    timeout check           10s
    maxconn                 3000

#---------------------------------------------------------------------
# main frontend which proxys to the backends
#---------------------------------------------------------------------
frontend localhost
    bind ${MY_IP}:${PORT_EXPOSE} ssl crt /etc/haproxy/tls/local.pem
    mode http
    default_backend application


#---------------------------------------------------------------------
# round robin balancing between the various backends
#---------------------------------------------------------------------
backend application
    mode http
    balance roundrobin
    option forwardfor
    server app 127.0.0.1:${PORT_LOCAL} check
    http-request set-header X-Forwarded-Port %[dst_port]
    http-request add-header X-Forwarded-Proto https if { ssl_fc }
EOF



echo "${OS_DISTRO}: Checking config"
################################################################################
su -s /bin/sh -c "exec haproxy -c -f /etc/haproxy/haproxy.cfg" haproxy

echo "${OS_DISTRO}: Launching container application"
################################################################################
exec haproxy -db -V -f /etc/haproxy/haproxy.cfg
