#!/bin/sh
set -x
set -e

mkdir -p /opt/stack

git clone ${OS_REPO_URL} /opt/stack/${OS_COMP}
  cd /opt/stack/${OS_COMP}
  git checkout ${OS_REPO_COMMIT}
  cd /

git clone ${OS_REPO_URL_1} -b ${OS_REPO_BRANCH_1} --depth 1 /opt/stack/${OS_COMP_1}
cd /opt/stack/${OS_COMP_1}
  git fetch git://git.openstack.org/openstack/networking-ovn refs/changes/05/315305/18
  git checkout FETCH_HEAD
  cd /

git clone ${OS_REPO_URL_2} -b ${OS_REPO_BRANCH_2} --depth 1 /opt/stack/${OS_COMP_2}

pip --no-cache-dir install /opt/stack/${OS_COMP}
pip --no-cache-dir install /opt/stack/${OS_COMP_1}
pip --no-cache-dir install /opt/stack/${OS_COMP_2}

mkdir -p /var/log/${OS_COMP}
mkdir -p /var/lib/${OS_COMP}/lock
mkdir -p /var/lib/${OS_COMP}/state
mkdir -p /var/lib/${OS_COMP}/state/lbaas

mkdir -p /etc/${OS_COMP}
mkdir -p /var/cache/${OS_COMP}

cp /opt/stack/neutron/etc/*.ini /etc/${OS_COMP}/
cp /opt/stack/neutron/etc/*.conf /etc/${OS_COMP}/
cp /opt/stack/neutron/etc/*.json /etc/${OS_COMP}/

if [ "$OS_DISTRO" = "HarborOS-Alpine" ]; then
  addgroup ${OS_COMP} -g 1000
  adduser -u 1000 -D -s /bin/false -G ${OS_COMP} ${OS_COMP}
else
  groupadd ${OS_COMP} -g 1000
  adduser -u 1000 -g ${OS_COMP} --system  ${OS_COMP}
fi;

chown -R ${OS_COMP}:${OS_COMP} /var/log/${OS_COMP}
chown -R ${OS_COMP}:${OS_COMP} /var/lib/${OS_COMP}
chown -R ${OS_COMP}:${OS_COMP} /var/cache/${OS_COMP}

rm -rf /opt/stack
