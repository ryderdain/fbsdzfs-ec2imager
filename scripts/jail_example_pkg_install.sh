#!/bin/sh

################################################################
# BASE PACKAGES - CONFIGURE SOURCE REPOSITORIES
################################################################

make_pkgconf() {
    jailpath="${1}"
    mkdir -p $jailpath/usr/local/etc/pkg/repos
    cat > $jailpath/usr/local/etc/pkg.conf <<EOF
repos_dir: ["/usr/local/etc/pkg/repos"]
}
EOF
    cat > $jailpath/usr/local/etc/pkg/repos/FreeBSD.conf <<EOF
FreeBSD: {
  url: "pkg+http://pkg.FreeBSD.org/\${ABI}/quarterly",
  mirror_type: "srv",
  signature_type: "fingerprints",
  fingerprints: "/usr/share/keys/pkg",
  enabled: yes
  priority: 0
}
EOF
}

# Packages to pre-install on host and all jails
base_packages="pkg ca_root_nss sudo bash tmux vim-console daemontools"

# Start by reconfiguring the host's package mirror to keep
# things in sync.
make_pkgconf
package_repo=${PACKAGE_REPO:-FreeBSD}; export package_repo

# Install host's packages (this is an additional pkg-add routine
# just-in-case some packages are needed specifically for
# managing your jails.
ASSUME_ALWAYS_YES=true; export ASSUME_ALWAYS_YES
IGNORE_OSVERSION=yes; export IGNORE_OSVERSION
pkg install -r "$package_repo" -q -y -f $base_packages

# Now install each of the jails in turn.
for j in $(jls path)
do
    # Expect to run this in ZFS chroot environment. 
    j=${j#/mnt}
    echo "nameserver 8.8.8.8" > "$j/etc/resolv.conf"
    make_pkgconf "$j"
    case "$(basename $j)" in 
    'dummy-jail')
        jail_packages="nginx netqmail";;
    '*')
        jail_packages="";;
    esac
    pkg -c $j install -r "$package_repo" -q -y $base_packages $jail_packages
    pkg -c $j clean -a -q
done
