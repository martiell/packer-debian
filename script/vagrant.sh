#!/bin/sh -eux

VAGRANT_USER=${VAGRANT_USER:-vagrant}
VAGRANT_HOME=${VAGRANT_HOME:-/home/${VAGRANT_USER}}
# https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant.pub
VAGRANT_INSECURE_KEY="ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTky\
rtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFt\
dOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2\
hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvx\
hMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8t\
ehUc9c9WhQ== \
vagrant insecure public key"

# Add vagrant user (if it doesn't already exist)
if ! id -u $VAGRANT_USER >/dev/null 2>&1; then
    echo '# Adding Vagrant user'
    /usr/sbin/groupadd $VAGRANT_USER
    /usr/sbin/useradd $VAGRANT_USER \
      -g $VAGRANT_USER \
      -d $VAGRANT_HOME \
      -G sudo \
      --create-home
    echo "${VAGRANT_USER}:${VAGRANT_USER}" | chpasswd
fi

echo '# Installing Vagrant SSH key'
mkdir -pm 700 $VAGRANT_HOME/.ssh
umask 177
echo "${VAGRANT_INSECURE_KEY}" > $VAGRANT_HOME/.ssh/authorized_keys
chown -R $VAGRANT_USER:$VAGRANT_USER $VAGRANT_HOME/.ssh

echo '# Enable sudo without password for Vagrant user'
umask 0337
echo "$VAGRANT_USER ALL=NOPASSWD:ALL" > /etc/sudoers.d/vagrant

echo '# Writing timestamp for Vagrant box build'
umask 0022
date --utc > /etc/vagrant_box_build_time

echo '# Configuring SSH server'
printf '\nUseDNS no\n' >> /etc/ssh/sshd_config
