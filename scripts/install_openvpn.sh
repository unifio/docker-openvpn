#!/bin/sh

set -e

logger() {
  DT=$(date '+%Y/%m/%d %H:%M:%S')
  echo "$DT install_openvpn_deb.sh: $1"
}

logger "Executing"

logger "Installing OpenVPN apt repositories"
curl -fsSL https://swupdate.openvpn.net/repos/repo-public.gpg|apt-key add -
echo "deb http://build.openvpn.net/debian/openvpn/stable stretch main" > /etc/apt/sources.list.d/openvpn-offical.list

apt-get -y update

logger "Installing OpenVPN supporting packages"
apt-get -y install \
  udev \
  iptables

logger "Installing OpenVPN"
if [ -z "$OPENVPN_VERSION" ]; then
  logger "\$OPENVPN_VERSION not specified, installing latest"
  apt-get -y install openvpn
else
  apt-get -y install openvpn=${OPENVPN_VERSION}*
fi
logger "Setting up OpenVPN config"
mkdir -p /etc/openvpn/keys
mkdir -p /var/run/openvpn

logger "Installing confd"
curl -fsSL https://github.com/kelseyhightower/confd/releases/download/v${CONFD_VERSION}/confd-${CONFD_VERSION}-linux-amd64 -o /tmp/confd
mv /tmp/confd /usr/local/bin
chmod +x /usr/local/bin/confd

logger "Installing awscli"
apt-get -y install awscli

#logger "Installing openvpn-cert-generator pip package"
#apt-get -y install python python-pip git python-jinja2
#pip install git+https://github.com/unifio/openvpn-cert-generator.git

#touch index.txt
# echo 01 > serial
# KEY_DIR="/tmp" S3_CERT_ROOT_PATH="" KEY_SIZE=1024 openvpn-cert-generator
