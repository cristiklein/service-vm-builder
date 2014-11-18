#!/bin/bash

# Script will be called with the guest's chroot as first argument,
# so you can use chroot $1 <cmd> to run code in the virtual machine.

# Exit on error
set -e

# Don't start any daemons after installation and don't ask any questions
export RUNLEVEL=1
export DEBIAN_FRONTEND=noninteractive

echo "Installing Apache2"
chroot $1 apt-get -yq install apache2

echo "Installing PHP"
chroot $1 apt-get -yq install libapache2-mod-php5

echo "Installing MySQL"
chroot $1 apt-get -yq install mysql-server


