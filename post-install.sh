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
	libapache2-mod-php5 php5-mysql mysql-server

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
chroot $1 sed -i -e 's|key_buffer[^_]|key_buffer_size|' /etc/mysql/my.cnf
chroot $1 tee -a /etc/mysql/my.cnf <<EOF
[mysqld]
# Do not check permissions
skip-grant-tables
# Set to match Apache threads connections
max_connections = 100
# Store tables compactly
innodb_file_per_table
innodb_file_format=BARRACUDA
EOF

#
# Reduce noise
#
chroot $1 dpkg-divert --rename /etc/init/cron.conf
chroot $1 dpkg-divert --rename /etc/init.d/ondemand


#
# Install RUBiS
#
echo "Installing RUBiS App..." >&2
mkdir -p $1/var/www/rubis
(cd $1/var/www; git clone https://github.com/cloud-control/brownout-lb-rubis.git rubis)
chroot $1 sed -i -e 's|DocumentRoot.*|DocumentRoot /var/www/rubis|' /etc/apache2/sites-enabled/000-default.conf

echo "Installing RUBiS Database..." >&2
chroot $1 /usr/sbin/mysqld --skip-networking & MYSQL_DAEMON=$!
chroot $1 mysqladmin --wait ping
(echo "SET unique_checks=0; SET foreign_key_checks=0;"; zcat rubis.sql.gz) | chroot $1 mysql
chroot $1 mysqladmin shutdown
