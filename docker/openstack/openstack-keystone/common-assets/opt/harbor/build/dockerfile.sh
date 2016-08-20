#!/bin/sh
set -x
set -e

mkdir -p /opt/stack

git clone ${OS_REPO_URL} -b ${OS_REPO_BRANCH} --depth 1 /opt/stack/${OS_COMP}

pip --no-cache-dir install /opt/stack/${OS_COMP}

mkdir -p /etc/${OS_COMP}

cp -rf /opt/stack/${OS_COMP}/etc/* /etc/${OS_COMP}/

rm -rf /opt/stack/${OS_COMP}

mkdir -p /var/log/${OS_COMP}
mkdir -p /var/lib/${OS_COMP}
mkdir -p /var/cache/${OS_COMP}

groupadd ${OS_COMP} -g 1000
adduser -u 1000 -g ${OS_COMP} --system  ${OS_COMP}

chown -R ${OS_COMP}:${OS_COMP} /var/log/${OS_COMP}
chown -R ${OS_COMP}:${OS_COMP} /var/lib/${OS_COMP}
chown -R ${OS_COMP}:${OS_COMP} /var/cache/${OS_COMP}
