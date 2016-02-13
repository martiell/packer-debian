#!/bin/sh
set -e

if [ $PACKER_BUILDER_TYPE = vmware-iso ]; then
    echo "# Installing VMware Tools"
    rm -f linux.iso
    apt-get install -y \
      --no-install-recommends \
      open-vm-tools-dkms \
      open-vm-tools \
      linux-headers-$(uname -r)
    mkdir /mnt/hgfs
fi

if [ $PACKER_BUILDER_TYPE = virtualbox-iso ]; then
    echo "# Installing VirtualBox guest additions"
    apt-get install -y \
      dkms \
      build-essential \
      linux-headers-$(uname -r)

    VBOX_VERSION=$(cat /home/vagrant/.vbox_version)
    mount -o loop /home/vagrant/VBoxGuestAdditions_${VBOX_VERSION}.iso /mnt
    sh /mnt/VBoxLinuxAdditions.run --nox11
    umount /mnt
    rm ${VAGRANT_HOME}/VBoxGuestAdditions_${VBOX_VERSION}.iso
    rm ${VAGRANT_HOME}/.vbox_version

    if [[ $VBOX_VERSION = "4.3.10" ]]; then
        ln -s /opt/VBoxGuestAdditions-4.3.10/lib/VBoxGuestAdditions /usr/lib/VBoxGuestAdditions
    fi
fi

if [ -n "$NO_DKMS" ]; then
  echo "# Removing linux headers"
  find /lib/modules/ -path "*/*/dkms/*" | tar -zcPT- -f /tmp/vmtools.tgz
  apt-get remove -y \
    --auto-remove \
    --purge \
    open-vm-tools-dkms \
    linux-headers-$(uname -r)
  cat <<-EOF > /etc/apt/preferences.d/linux
	Package: linux-image-$(uname -r)
	Pin: origin *
	Pin-Priority: 1000

	Package: linux-image-*
	Pin: origin *
	Pin-Priority: -1
	EOF
  tar zxvPf /tmp/vmtools.tgz |
    awk -F/ '{gsub(".ko$", "", $NF); print $NF;}' |
    tee -a /etc/modules > /dev/null
  rm /tmp/vmtools.tgz
  depmod
  update-initramfs -u -k $(uname -r)
fi
