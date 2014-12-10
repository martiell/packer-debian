#!/bin/bash -eux
# Whiteout root
count=$(df --sync -kP / | tail -n1  | awk -F ' ' '{print $4}')
let count--
dd if=/dev/zero of=/tmp/whitespace bs=1024 count=$count
rm /tmp/whitespace

# Whiteout /boot
count=$(df --sync -kP /boot | tail -n1 | awk -F ' ' '{print $4}')
let count--
dd if=/dev/zero of=/boot/whitespace bs=1024 count=$count
rm /boot/whitespace

# Zero out the free space to save space in the final image
dd if=/dev/zero of=/EMPTY bs=1M
rm -f /EMPTY

# Make sure we wait until all the data is written to disk, otherwise
# Packer might quit too early
sync
