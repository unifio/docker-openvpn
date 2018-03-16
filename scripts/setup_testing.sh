#!/bin/sh

set -e

logger() {
  DT=$(date '+%Y/%m/%d %H:%M:%S')
  echo "$DT setup_testing.sh: $1"
}

logger "Executing"

logger "Install goss"
# See https://github.com/aelsabbahy/goss/releases for release versions
curl -fsSL https://github.com/aelsabbahy/goss/releases/download/v${GOSS_VERSION}/goss-linux-amd64 -o /usr/local/bin/goss
chmod +rx /usr/local/bin/goss

logger "setting up test space"
mkdir -p /opt/tests
