#!/bin/ksh

echo "Updating OpenBSD"
uname -a

# update packages
pkg_add -uUv

# update firmware
fw_update

# patch OpenBSD
syspatch

# list installed patches
syspatch -l

# Upgrade to next release
#sysupgrade
#sysmerge

echo "Update script finished!"
