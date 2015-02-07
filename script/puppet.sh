#!/bin/sh -eux

CODENAME=$(. /etc/os-release; v="${VERSION##*(}"; v="${v%)}"; echo "$v")
echo "==> Installing Puppet"

echo "Adding Puppet repository for: ${CODENAME}"
DEB_NAME=puppetlabs-release-${CODENAME}.deb
wget http://apt.puppetlabs.com/${DEB_NAME}
dpkg -i ${DEB_NAME}
echo "Installing Puppet"
apt-get install -y puppet
rm -f ${DEB_NAME}
