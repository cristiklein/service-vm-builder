#!/bin/bash

# Script will be called with the guest's chroot as first argument,
# so you can use chroot $1 <cmd> to run code in the virtual machine.

# Exit on error
set -e

# Don't start any daemons after installation and don't ask any questions
export RUNLEVEL=1
export DEBIAN_FRONTEND=noninteractive

echo "Installing Apache2, PHP, MySQL"
chroot $1 apt-get -yq install apache2 apache2-mpm-event \
	libapache2-mod-php5 mysql-server

echo "Setting up serial console"
chroot $1 tee /etc/init/ttyS0.conf <<EOF
# ttyS0 - getty
#
# This service maintains a getty on ttyS0 from the point the system is
# started until it is shut down again.

start on stopped rc or RUNLEVEL=[12345]
stop on runlevel [!12345]

respawn
exec /sbin/getty -L 115200 ttyS0 vt102
EOF
chroot $1 dpkg-divert --rename /etc/init/tty1.conf
chroot $1 dpkg-divert --rename /etc/init/tty2.conf
chroot $1 dpkg-divert --rename /etc/init/tty3.conf
chroot $1 dpkg-divert --rename /etc/init/tty4.conf
chroot $1 dpkg-divert --rename /etc/init/tty5.conf
chroot $1 dpkg-divert --rename /etc/init/tty6.conf

# Kernel serial console
chroot $1 sed -i -e 's|^timeout.*|timeout 0|' /boot/grub/menu.lst
chroot $1 sed -i -e 's|^# defoptions=.*|# defoptions=console=ttyS0|' /boot/grub/menu.lst
chroot $1 update-grub

# Disable Plymouth
chroot $1 dpkg-divert --rename /etc/init/plymouth.conf
chroot $1 dpkg-divert --rename /etc/init/plymouth-log.conf
chroot $1 dpkg-divert --rename /etc/init/plymouth-ready.conf
chroot $1 dpkg-divert --rename /etc/init/plymouth-shutdown.conf
chroot $1 dpkg-divert --rename /etc/init/plymouth-splash.conf
chroot $1 dpkg-divert --rename /etc/init/plymouth-stop.conf
chroot $1 dpkg-divert --rename /etc/init/plymouth-upstart-bridge.conf
