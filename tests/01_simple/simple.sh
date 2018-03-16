#!/bin/bash

set -e

echo "start openvpn server"
bash -c "/start_server.sh --daemon"
sleep 2
echo "do some tests"
pushd /opt/tests/01_simple
goss --gossfile simple.yaml validate
popd

echo "teardown openvpn server"
kill $(pidof openvpn)
