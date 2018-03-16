#!/bin/bash

set -e

sleep 2
echo "start openvpn client connection"
bash -c "openvpn --daemon --status /var/run/invalid_client.status 1 --cd /etc/openvpn/keys --config dummy.ovpn --connect-retry 2 --connect-retry-max 2"
sleep 5

echo "run invalid_client tests"
pushd /opt/tests/03_invalid_client
goss --gossfile invalid_client.yaml validate
sleep 2
echo "run status tests after status file updates"
goss --gossfile invalid_client_stats.yaml validate
popd
