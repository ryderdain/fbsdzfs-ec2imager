#!/bin/sh
################################################################################
# CONFIG
################################################################################

# Packages which are pre-installed
BASE_PACKAGES="ec2-scripts firstboot-freebsd-update firstboot-growfs firstboot-pkgs"


################################################################################
# PACKAGE INSTALLATION
################################################################################

echo "nameserver 8.8.8.8" > /etc/resolv.conf

ASSUME_ALWAYS_YES=true; export ASSUME_ALWAYS_YES
IGNORE_OSVERSION=yes; export IGNORE_OSVERSION
pkg bootstrap -f
pkg install -y $BASE_PACKAGES
