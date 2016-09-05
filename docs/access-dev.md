# Development environment access

Once the hosts is online you can connect via ssh with the username ```harbor```.
The following ports are required for interconnectivity between nodes:

 * 22/tcp <-- SSH
 * 443/tcp <-- All apis and Web UI
 * 80/tcp <-- Insecure HTTP assets
 * 9090/tcp <-- Management Console
 * 4001/tcp <-- Public(insecure) etcd
 * 6640/tcp <-- OpenvSwitch db(s)
 * 6642/tcp <-- OVN Southbound db
 * 6081/udp <-- Geneve

By default the master node will store the access credentials automcaticly generated during the node setup for the IPA server at ```/etc/harbor/harbor-auth.conf``` this file should **not** be left on the node for a production deployment once the environment has been bootstrapped.

Harbor makes extensive use of SNI for external access, all http access requires your dns to resolve the following domains to your instances ip(s) where ```${DOMAIN}``` should be replaced with the appropriate domain.

```
freeipa.${DOMAIN}
ipsilon.${DOMAIN}
keystone.${DOMAIN}
api.${DOMAIN}
```
