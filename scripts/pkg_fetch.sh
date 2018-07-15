#!/bin/sh
################################################################################
# CONFIG
################################################################################

# Packages which are pre-installed
INSTALLED_PACKAGES="pkg ca_root_nss ec2-scripts awscli sudo bash"

# We'll store these in the mounted ZFS at /mnt
DESTDIR="/mnt/tmp/"

################################################################################
# PACKAGE INSTALLATION
################################################################################

env ASSUME_ALWAYS_YES=true pkg bootstrap -yf
for package in $INSTALLED_PACKAGES
do
    pkg fetch -y -d -o $DESTDIR $package
done

