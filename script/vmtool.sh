#!/bin/sh -eux

if [[ $PACKER_BUILDER_TYPE = vmware-iso ]]; then
    echo "# Installing VMware Tools"
    rm -f linux.iso
    apt-get install -y \
      --no-install-recommends \
      open-vm-tools-dkms \
      open-vm-tools \
      linux-headers-$(uname -r)
    mkdir /mnt/hgfs
fi

if [[ $PACKER_BUILDER_TYPE = virtualbox-iso ]]; then
    echo "# Installing VirtualBox guest additions"
    apt-get install -y linux-headers-$(uname -r) build-essential
    apt-get install -y dkms

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
