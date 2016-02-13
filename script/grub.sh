#!/bin/sh
# Set grub timeout
# This value can't be preseeded: see http://bugs.debian.org/747515
set -e

timeout=2
sed -ri "s/(GRUB_TIMEOUT)=.*/\1=${timeout}/" /etc/default/grub
update-grub
