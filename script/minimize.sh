#!/bin/bash -eux

UNINSTALL="apt-get -y --purge --auto-remove remove"

echo "# Removing all linux kernels except the currrent one"
dpkg-query -f '${package}\n' -W 'linux-image-*' | \
  grep -v linux-image-$(uname -r)\$ | \
  xargs $UNINSTALL

echo "# Removing linux headers"
dpkg-query -f '${package}\n' -W 'linux-headers-*' | \
  xargs $UNINSTALL

echo "# Clean up orphaned packages with deborphan"
apt-get -y --no-install-recommends install deborphan
while [ -n "$(deborphan --guess-all --libdevel)" ]; do
    deborphan --guess-all --libdevel | xargs apt-get -y purge
done
$UNINSTALL deborphan

echo "# Removing APT cache"
apt-get -y clean
echo "# Removing APT lists"
find /var/lib/apt -depth -name extended_states -prune -o -type f -delete
echo "# Removing caches"
find /var/cache -type f -delete

echo "# Cleaning up leftover dhcp leases"
rm -f /var/lib/dhcp/*

echo "# Cleaning up tmp"
find /tmp -mindepth 1 -xdev -delete

# Clean up log files
find /var/log
#find /var/log -type f | while read f; do echo -ne '' > $f; done;
