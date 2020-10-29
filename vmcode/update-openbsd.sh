#!/bin/ksh

echo "Updating OpenBSD"
uname -a

# update packages
pkg_add -uUv

# update Drivers + OS
fw_update
syspatch

# list installed patches
syspatch -l

# syspatch
# sysmerge

echo "Update script finished!"
