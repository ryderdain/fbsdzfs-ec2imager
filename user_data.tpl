#!/bin/sh
# vim: ft=sh:ts=4:sw=4:expandtab

# We turn this off as our builder won't be the same anyway.
sysrc firstboot_freebsd_update_enable=NO
sysrc ec2_fetchkey_enable=YES
sysrc growfs_enable=NO

# Strange behavior often noted on instances with checksums turned on.
sysrc ifconfig_xn0="DHCP -lro -tso -txcsum -rxcsum"
sysrc firstboot_pkgs_enable=YES
sysrc firstboot_pkgs_list="ec2-scripts awscli sudo bash curl"
sysrc hostname='packer-imagebuilder'

# Make life easy for the builder's user
mkdir -p /usr/local/etc/sudoers.d
cat > /usr/local/etc/sudoers.d/wheel <<EOF
%wheel ALL=(ALL) NOPASSWD: ALL
EOF

# Only needed when initial firstboot_pkgs_list fails for builder (e.g.,
# 10.3-RELEASE image ingores this, leaves sudo unavailable)
su root -c "env ASSUME_ALWAYS_YES=true pkg bootstrap -yf"
su root -c "env ASSUME_ALWAYS_YES=true pkg install -y sudo bash curl"

# Packer user requires sudo access, try not to collide
# with standard ec2-user account (uid 1001)
pw useradd packer -c '' -u 1002 -m -G wheel -h - 
mkdir -m 700 /home/packer/.ssh/
touch /home/packer/.ssh/authorized_keys
chown -Rv packer:packer /home/packer/.ssh/
cat > /home/packer/.ssh/authorized_keys <<EOF
PUBLIC_SSH_KEY
EOF

# Checking settings
cat /etc/rc.conf >&2
