#!/bin/ksh

echo "Updating OpenBSD"

# update packages
pkg_add -uUv

# update Drivers + OS
fw_update
syspatch

# syspatch
# sysmerge

echo "Update script finished!"
