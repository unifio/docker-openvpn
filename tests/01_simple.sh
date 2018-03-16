#!/bin/bash

set -e

docker run \
  -e OPENVPN_S3_PULL_CERTS=false \
  -e OPENVPN_TLS_ENABLE=false \
  -e OPENVPN_COMPRESS_ALGORITHM=lzo \
  -e OPENVPN_KEY_DHSIZE=1024 \
  --rm \
  --cap-add=NET_ADMIN \
  --device=/dev/net/tun \
  -v ${TEMPLATE_DIR}/test_certs/:/etc/openvpn/keys/ \
  unifio/openvpn:candidate \
  /opt/tests/01_simple/simple.sh

