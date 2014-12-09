#!/bin/bash -eux

# Remove some packages to get a minimal install
echo "==> Removing all linux kernels except the currrent one"
dpkg-query -f '${package}\n' -W 'linux-image-*' | \
  grep -v linux-image-$(uname -r)\$ | \
  xargs apt-get -y autoremove --purge

echo "==> Removing linux headers"
dpkg-query -f '${package}\n' -W 'linux-headers-*' | \
  xargs apt-get -y autoremove --purge

echo "==> Removing development tools"
apt-get -y --purge autoremove build-essential

echo "==> Removing obsolete networking components"
#apt-get -y purge ppp pppconfig pppoeconf

echo "==> Removing other oddities"
#apt-get -y purge popularity-contest installation-report wireless-tools wpasupplicant

# Clean up the apt cache
apt-get -y autoremove --purge
apt-get -y clean

# Clean up orphaned packages with deborphan
apt-get -y install deborphan
#while [ -n "$(deborphan --guess-all --libdevel)" ]; do
#    deborphan --guess-all --libdevel | xargs apt-get -y purge
#done
apt-get -y purge deborphan dialog

echo "==> Removing APT files"
find /var/lib/apt -type f | xargs rm -f
#echo "==> Removing anything in /usr/src"
#rm -rf /usr/src/*
echo "==> Removing caches"
find /var/cache -type f -exec rm -rf {} \;
