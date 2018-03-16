#!/bin/sh

set -e

logger() {
  DT=$(date '+%Y/%m/%d %H:%M:%S')
  echo "$DT teardown.sh: $1"
}

logger "Executing"
export DEBIAN_FRONTEND=noninteractive
apt-get remove -y \
    curl \
    gnupg \
  && apt-get clean autoclean \
  && apt-get autoremove -y \
  && rm -rf \
    /var/lib/apt/lists/ \
    /tmp/* \
    /var/tmp/*

