#!/bin/sh

set -e

logger() {
  DT=$(date '+%Y/%m/%d %H:%M:%S')
  echo "$DT setup.sh: $1"
}

logger "Executing"
export DEBIAN_FRONTEND=noninteractive
apt-get -y update
apt-get -y install curl gnupg iputils-ping
