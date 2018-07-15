#!/bin/sh

curl -o /tmp/zfsinstall https://raw.githubusercontent.com/mmatuska/mfsbsd/master/tools/zfsinstall
sed -i.bkp '/FS_LIST/s/"var tmp"/"usr var tmp"/' /tmp/zfsinstall
chmod a+x /tmp/zfsinstall

# Basic install of ZFS with 1G swap.
kldload zfs
/tmp/zfsinstall -d /dev/xbd1 -u http://ftp.freebsd.org/pub/FreeBSD/releases/amd64/${FREEBSD_VERSION}/ -p zroot -s 1G

# Provide network access while in chroot'd environment
echo "nameserver 8.8.8.8" > /mnt/etc/resolv.conf
mount -t devfs devfs /mnt/dev

# Update freebsd
freebsd-update -b /mnt --not-running-from-cron fetch
freebsd-update -b /mnt --not-running-from-cron install
sleep 3
