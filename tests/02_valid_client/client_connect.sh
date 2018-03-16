#!/bin/bash

set -e

sleep 2
echo "start openvpn client connection"
bash -c "openvpn --daemon --status /var/run/valid_client.status 1 --cd /etc/openvpn/keys --config client.ovpn --connect-retry 2 --connect-retry-max 2"
sleep 2

echo "run valid_client tests"
pushd /opt/tests/02_valid_client
goss --gossfile valid_client.yaml validate
sleep 2
echo "run status tests after status file updates"
goss --gossfile valid_client_stats.yaml validate
popd

echo "teardown openvpn server"
kill $(pidof openvpn)
