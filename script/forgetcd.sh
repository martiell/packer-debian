#!/bin/sh -eux

echo "# Removing CD-ROM entries from sources.list."
sed -i "/deb cdrom:/,+1d" /etc/apt/sources.list
