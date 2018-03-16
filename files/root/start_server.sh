#!/bin/bash

set -e

echo "start_server"

echo "enabling iptables NAT"
# TODO: might need to rethink and whitelist at this level
# to make it more compatible with different docker networking modes.
# if so, might just want to spell out the iptable rules here.
# - maybe a CIDR whitelist of what to allow through FWD rules
/sbin/iptables-restore /etc/iptables/rules.v4

if [[ $OPENVPN_S3_PULL_CERTS = "true" ]] && [[ ${OPENVPN_S3_CERT_PATH:-} ]]; then
  echo "pulling certs from s3"
  aws s3 cp s3://${OPENVPN_S3_CERT_PATH} /etc/openvpn/keys --recursive
  chmod 0700 -R /etc/openvpn/keys
fi

echo "generating server.conf"
confd -onetime -backend $OPENVPN_CONFIG_BACKEND
if [ -f /etc/openvpn/server-append.conf ]; then
  echo "appending server-append.conf contents to server.conf"
  cat /etc/openvpn/server-append.conf >> /etc/openvpn/server.conf
fi

echo "starting server"
# no need for gosu, openvpn has options ot change user/group on start
exec openvpn --config /etc/openvpn/server.conf $*
