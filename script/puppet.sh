#!/bin/bash -eux

echo "==> Installing Puppet"
DISTRIB_CODENAME=wheezy
DEB_NAME=puppetlabs-release-${DISTRIB_CODENAME}.deb
wget http://apt.puppetlabs.com/${DEB_NAME}
dpkg -i ${DEB_NAME}
if [[ ${CM_VERSION:-} == 'latest' ]]; then
  echo "Installing latest Puppet version"
  apt-get install -y puppet
else
  echo "Installing Puppet version $CM_VERSION"
  apt-get install -y puppet-common=$CM_VERSION puppet=$CM_VERSION
fi
rm -f ${DEB_NAME}
