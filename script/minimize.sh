#!/bin/bash -eux

# Remove some packages to get a minimal install
echo "==> Removing all linux kernels except the currrent one"
dpkg-query -f '${package}\n' -W 'linux-image-*' | \
  grep -v linux-image-$(uname -r)\$ | \
  xargs apt-get -y purge

echo "==> Removing linux headers"
dpkg-query -f '${package}\n' -W 'linux-headers-*' | \
  xargs apt-get -y purge

apt-get -y autoremove --purge

echo "==> Removing development tools"
apt-get -y purge build-essential
apt-get -y autoremove --purge

# Clean up the apt cache
apt-get -y autoremove --purge
apt-get -y clean

# Clean up orphaned packages with deborphan
apt-get -y install deborphan
while [ -n "$(deborphan --guess-all --libdevel)" ]; do
    deborphan --guess-all --libdevel | xargs apt-get -y purge
done
apt-get -y purge deborphan dialog
apt-get -y autoremove --purge

echo "==> Removing APT lists"
find /var/lib/apt -depth -name extended_states -prune -o -type f -delete
echo "==> Removing caches"
find /var/cache -type f -exec rm -rf {} \;

# Make sure Udev doesn't block our network
# http://6.ptmc.org/?p=164
echo "cleaning up udev rules"
rm -rf /dev/.udev/
rm /lib/udev/rules.d/75-persistent-net-generator.rules

echo "==> Cleaning up leftover dhcp leases"
rm -f /var/lib/dhcp/*

echo "==> Cleaning up tmp"
rm -rf /tmp/*

# Cleanup apt cache
apt-get -y autoremove --purge
apt-get -y clean

# Remove Bash history
unset HISTFILE
rm -f /root/.bash_history
rm -f /home/vagrant/.bash_history

# Clean up log files
#find /var/log -type f | while read f; do echo -ne '' > $f; done;
