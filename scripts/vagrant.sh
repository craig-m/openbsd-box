#!/bin/ksh

# run by Vagrant on provision/up (called in Vagrantfile)

echo "vagrant.sh running"

# stop mail server
# rcctl stop smtpd
# rcctl disable smtpd

# disable sound
rcctl stop sndiod
rcctl disable sndiod

echo "vagrant.sh finished"
logger "vagrant.sh finished"