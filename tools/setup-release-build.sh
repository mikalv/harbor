#!/bin/sh
set -x

cat > /etc/systemd/system/build-harbor.service <<EOF
[Unit]
Description=Builds HarborOS

[Service]
Type=simple
ExecStart=/usr/local/bin/build-harbor
EOF

cat > /etc/systemd/system/build-harbor.timer <<EOF
[Unit]
Description=Builds HarborOS Every 60 minutes

[Timer]
OnCalendar=*-*-* *:00:00
EOF

cat > /usr/local/bin/build-harbor <<EOF
#!/bin/bash
docker rm -f freeipa-repo || true
docker rm -f mandracchio-repo || true
docker rm -f ipsilon-repo || true
docker rm -f openvswitch-repo || true
docker rm \$(docker ps -a -q) || true
docker rmi \$(docker images -q -f dangling=true) || true
docker run -d --name openvswitch-repo -p 172.17.0.1:80:80/tcp port/openvswitch-rpm:latest
docker run -d --name mandracchio-repo -p 172.17.0.1:81:80/tcp port/mandracchio-rpms:latest
docker run -d --name freeipa-repo -p 172.17.0.1:83:80/tcp port/freeipa-rpm:latest
docker run -d --name ipsilon-repo -p 172.17.0.1:82:80/tcp port/ipsilon-rpm:latest
docker run -d --name cinder-docker-repo -p 172.17.0.1:83:80/tcp port/openstack-cinder-docker-rpm:latest
cd /home/harbor/Documents/Builder/github/harbor
./tools/update-build-links
./tools/make-scripts-exec.sh
./tools/build-all-docker-images --release --push #--squash
EOF
chmod +x /usr/local/bin/build-harbor

systemctl daemon-reload
systemctl enable build-harbor.timer
