#!/bin/bash

# Script will be called with the guest's chroot as first argument,
# so you can use chroot $1 <cmd> to run code in the virtual machine.

# Exit on error
set -e

# Don't start any daemons after installation and don't ask any questions
export RUNLEVEL=1
export DEBIAN_FRONTEND=noninteractive

#
# Install Apache2, PHP, MySQL
#
chroot $1 apt-get -yq install apache2 apache2-mpm-event \
	libapache2-mod-php5 mysql-server

#
# Setup serial console
#

# Login on serial
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

#
# Configure Apache
#
chroot $1 a2disconf other-vhosts-access-log
chroot $1 sed -i -e 's|CustomLog.*|# CustomLog removed to reduce noise|' /etc/apache2/sites-enabled/000-default.conf

#
# Configure MySQL
#
chroot $1 tee /etc/mysql/conf.d/skip-grant-tables.cnf <<EOF
[mysqld]
skip-grant-tables
EOF
chroot $1 tee /etc/mysql/conf.d/max-connections.cnf <<EOF
[mysqld]
max_connections = 100
EOF

#
# Reduce noise
#
chroot $1 dpkg-divert --rename /etc/init/cron.conf
