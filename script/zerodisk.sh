#!/bin/bash -eux
echo "Zero root partition."
count=$(df --sync -kP / | awk -F ' ' '{if (NR==2) print $4}')
let count--
dd if=/dev/zero of=/tmp/zero bs=1024 count=$count
rm /tmp/zero

echo "Zero /boot partition."
count=$(df --sync -kP /boot | awk -F ' ' '{if (NR==2) print $4}')
let count--
dd if=/dev/zero of=/boot/zero bs=1024 count=$count
rm /boot/zero

echo "Zero swap space."
for d in $(awk '$3 ~ /swap/ {print $1}' /etc/fstab ); do
  swapoff $d
  uuid=$(swaplabel $d | awk '/UUID:/{print $2}')
  label=$(swaplabel $d | awk '/LABEL:/{print $2}')
  sectors=$(blockdev --getsize /dev/mapper/vagrant--vg-swap_1)
  count=$(( $sectors / 2 ))
  dd if=/dev/zero of=$d bs=1024 count=$count
  mkswap -U "$uuid" -L "$label" $d
done

# Make sure we wait until all the data is written to disk, otherwise
# Packer might quit too early
echo "Sync."
sync
echo "Synced."
