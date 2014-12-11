#!/bin/bash -eux
# Whiteout root
count=$(df --sync -kP / | tail -n1  | awk -F ' ' '{print $4}')
let count--
dd if=/dev/zero of=/tmp/zero bs=1024 count=$count
rm /tmp/zero

# Whiteout /boot
count=$(df --sync -kP /boot | tail -n1 | awk -F ' ' '{print $4}')
let count--
dd if=/dev/zero of=/boot/zero bs=1024 count=$count
rm /boot/zero

# Make sure we wait until all the data is written to disk, otherwise
# Packer might quit too early
sync
