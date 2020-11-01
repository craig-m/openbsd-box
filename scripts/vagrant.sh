#!/bin/ksh

# run by Vagrant on provision/up

echo "vagrant.sh running"


# stop mail server
rcctl stop smtpd
rcctl disable smtpd

# disable sound
rcctl stop sndiod
rcctl disable sndiod

# update packages
pkg_add -uUv

# update firmware
fw_update

# patch OpenBSD
syspatch


echo "vagrant.sh finished"
