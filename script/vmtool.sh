#!/bin/bash -eux

if [[ $PACKER_BUILDER_TYPE =~ vmware ]]; then
    echo "==> Installing VMware Tools"
    apt-get install -y build-essential

    modprobe loop
    mount -o loop /home/vagrant/linux.iso /media/cdrom0
    tar zxf /media/cdrom/VMwareTools-*.tar.gz -C /tmp/
    /tmp/vmware-tools-distrib/vmware-install.pl -d
    umount /media/cdrom0
    rm -rf /tmp/VMwareTools-*
    rm linux.iso
fi

if [[ $PACKER_BUILDER_TYPE =~ virtualbox ]]; then
    echo "==> Installing VirtualBox guest additions"
    apt-get install -y linux-headers-$(uname -r) build-essential
    apt-get install -y dkms

    VBOX_VERSION=$(cat /home/vagrant/.vbox_version)
    mount -o loop /home/vagrant/VBoxGuestAdditions_${VBOX_VERSION}.iso /mnt
    sh /mnt/VBoxLinuxAdditions.run --nox11
    umount /mnt
    rm /home/vagrant/VBoxGuestAdditions_${VBOX_VERSION}.iso
    rm /home/vagrant/.vbox_version

    if [[ $VBOX_VERSION = "4.3.10" ]]; then
        ln -s /opt/VBoxGuestAdditions-4.3.10/lib/VBoxGuestAdditions /usr/lib/VBoxGuestAdditions
    fi
fi
