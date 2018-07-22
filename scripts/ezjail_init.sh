#!/bin/sh

# Need the binary available on the host.
env ASSUME_ALWAYS_YES=true pkg install -y ezjail

# We need to "fake out" the ezjail-admin script to install the
# jail base files to the correct paths at the start.
ln -s /mnt/usr/jails /usr/jails

# These will be our defaults for the pool.
cat > /usr/local/etc/ezjail.conf <<EOF
# Temporary setting for initialization
ezjail_jaildir="/usr/jails"

# Standard settings in use by remaining jails
ezjail_procfs_enable="NO"
ezjail_use_zfs="YES"
ezjail_use_zfs_for_jails="YES"
ezjail_jailzfs="zroot/jails"
EOF

# We don't need to set an alternative freebsd_version here.
ezjail-admin install 
#ezjail-admin install 2>/dev/null

# Finally, make sure the same tools are also available on the jail
# host. We have to bootstrap here in case it's the first time
# we're using the package manager on this host.
env ASSUME_ALWAYS_YES=true IGNORE_OSVERSION=yes pkg -c /mnt bootstrap -f
env ASSUME_ALWAYS_YES=true IGNORE_OSVERSION=yes pkg -c /mnt install -y ezjail
cp -v /usr/local/etc/ezjail.conf /mnt/usr/local/etc/ezjail.conf
