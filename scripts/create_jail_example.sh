#!/bin/sh

#################################################################
# NOTES
#
# This must be run from the host, the `ezjail-admin create`
# command will otherwise get confused by the temporary zpool's
# mountpoints of /mnt/.. for all jails.
#
# Due to editing the host /etc/rc.conf beyond the other configs,
# this is separated out into its own shell-script provisioner.
#
# It should be noted that jail creation is better suited to a 
# post-launch provisioner or by using a "follow-up" build that 
# runs against an existing ZFS-enabled jailhost image.
#################################################################

# Initial example will use IP addressing on the jails and PF to
# route traffic.
# Pass a cidr as JAIL_NETWORK to use an alternate internal
# network. Default is 172.16.99.0/24.
local_jail_network=${JAIL_NETWORK:-172.16.99.0/28}

# Our example jail's IP
dummy_jail_ip=${local_jail_network%.*}.2

# Set up rc.conf networking rules for lo1 to communicate with
# these jails, and of course to enable ezjail.
cat >> /mnt/etc/rc.conf <<EOF
cloned_interfaces="lo1"
ipv4_addrs_lo1="${dummy_jail_ip}"
pf_enable="YES"
ezjail_enable="YES"
EOF

# Set up a minimal pf.conf for routing traffic to and from our
# example "dummy-jail". Note escapes for literal "$" in pf.conf.
cat > /mnt/etc/pf.conf <<EOF
ext_if = "xn0"
jail_if = "lo1"
jails = "${local_jail_network}"
dummy_jail="$dummy_jail_ip"

set skip on lo0

# grant all jails internet access via the external interface
nat on xn0 from $jails to {!xn0:0} -> xn0:0

# dummy-jail has a basic webserver 
rdr on \$ext_if proto tcp to port 80 -> \$dummy_jail port 80
rdr on \$ext_if proto tcp to port 443 -> \$dummy_jail port 443

block drop
antispoof for \$ext_if inet

# Not recommended to block icmp
pass on \$ext_if inet proto icmp
pass on \$ext_if inet6 proto icmp6 all

# Keep your SSH access to the host open
pass in on xn0 proto tcp to xn0:0 port 22

# Keep HTTP traffic to the dummy-jail open.
pass in on \$jail_if
pass in on \$ext_if proto tcp to $dummy_jail port { 80, 443 }

# Don't block outgoing traffic.
pass out on \$ext_if
pass out on \$jail_if
EOF

# Let's make sure we can start up these jails ... just once.
ifconfig lo1 create
ifconfig lo1 inet $local_jail_network
ifconfig lo1 alias $dummy_jail_ip/32

# Create the jails here. 
ezjail-admin create -c zfs dummy-jail "$dummy_jail_ip"
service ezjail onestart dummy-jail

# Push the configs into place.
mkdir -p /mnt/usr/local/etc
cp -av /usr/local/etc/ezjail /mnt/usr/local/etc/ 

# Mount the jails for further setup
for f in /etc/fstab.*
do
    #mount -a -F "$f"
    cp -v "$f" /mnt/etc/
done
