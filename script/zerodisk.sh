#!/bin/sh
set -e

zero() {
  local file="$1"
  local dir=$(dirname "$file")
  local count
  count=$(df --sync -kP "$dir" | awk -F ' ' '{if (NR==2) print $4}')
  count=$(( count - 1 ))
  dd if=/dev/zero of="$file" bs=1024 count=$count
  rm "$file"
}

echo "# Zero root partition."
zero /tmp/zero

echo "# Zero /boot partition."
zero /boot/zero

echo "# Zero swap space."
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
echo "# Sync."
sync
echo "# Synced."
