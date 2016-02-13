#!/bin/sh
# Installs Puppet from the Puppet Labs repository.
set -e

if [ -z "$PUPPET" ]; then
  exit 0
fi

export DEBIAN_FRONTEND=noninteractive
CODENAME=$(. /etc/os-release; v="${VERSION##*(}"; v="${v%)}"; echo "$v")
echo "# Adding Puppet repository for: ${CODENAME}"
DEB_NAME=puppetlabs-release-${CODENAME}.deb
wget http://apt.puppetlabs.com/${DEB_NAME}
dpkg -i ${DEB_NAME}
rm -f ${DEB_NAME}

echo "# Installing Puppet"
apt-get update
apt-get install -y --no-install-recommends puppet
