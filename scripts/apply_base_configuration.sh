#!/bin/sh

echo " ### ## # #  Setting Up Image Requirements  # # ## ### " >&2
pw useradd ec2-user -u 1001 -G wheel -m -h - ''
su ec2-user -c "mkdir -v -m 700 /usr/home/ec2-user/.ssh"
su ec2-user -c "touch /usr/home/ec2-user/.ssh/authorized_keys"

pw useradd pseudoer -c 'Ersatz User' -u 1002 -m -G wheel -h - 
su pseudoer -c "mkdir -v -m 700 /usr/home/pseudoer/.ssh"
su pseudoer -c "touch /usr/home/pseudoer/.ssh/authorized_keys"

cat > /home/pseudoer/.ssh/authorized_keys <<EOF
PUBLIC_SSH_KEY
EOF

cat > /etc/rc.conf <<EOF
zfs_enable="YES"

ec2_configinit_enable="YES"
ec2_fetchkey_enable="YES"
ec2_ephemeralswap_enable="YES"
ec2_loghostkey_enable="YES"

firstboot_freebsd_update_enable="NO"
firstboot_pkgs_enable="YES"
firstboot_pkgs_list="ec2-scripts sudo"

growzfs_enable="YES"

ifconfig_DEFAULT="SYNCDHCP"
ifconfig_xn0="DHCP -lro -tso -txcsum -rxcsum"

sshd_enable="YES"
hostname='$FREEBSD_VERSION-imagetest'
EOF

cat >> /boot/loader.conf <<EOF
zfs_load="YES"
vfs.root.mountfrom="zfs:zroot/root"
# Make booting fast
autoboot_delay="-1"
beastie_disable="YES"
# Make the EC2 console work
console="comconsole"
hw.broken_txfifo="1"
EOF

mkdir -pv /usr/local/etc/sudoers.d
cat > /usr/local/etc/sudoers.d/wheel <<EOF
%wheel ALL=(ALL) NOPASSWD: ALL
EOF

touch /firstboot
touch /root/firstboot
