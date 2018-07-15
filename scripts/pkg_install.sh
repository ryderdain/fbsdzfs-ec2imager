#!/bin/sh

echo "nameserver 8.8.8.8" >> /mnt/etc/resolv.conf
env SHELL=/bin/sh chroot /mnt env IGNORE_OSVERSION=yes ASSUME_ALWAYS_YES=true pkg bootstrap -yf
chroot /mnt find /tmp/All/ -type f -name '*.txz' -exec sh -c 'env IGNORE_OSVERSION=yes pkg add {}' \;
