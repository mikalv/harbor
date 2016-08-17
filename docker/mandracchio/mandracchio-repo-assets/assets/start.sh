#!/bin/bash
cd tmp

rpm-ostree compose --repo=/srv/repo tree /opt/mandracchio/harbor-host.json
