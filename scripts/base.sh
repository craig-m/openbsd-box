#!/bin/sh

echo "OpenBSD base.sh setup script"
sleep 3s

set -e
set -x

# stop mail server (why is this even installed by default)
rcctl stop smtpd
rcctl disable smtpd

# disable sound
rcctl stop sndiod
rcctl disable sndiod

# update Drivers + OS
#fw_update
#syspatch

# install some packages
pkg_add -uUv
pkg_add -I dmidecode curl wget vim--no_x11 rsync--

# done
thetime=$(date +"%b %e %H:%M:%S")
echo "${thetime} base.sh finished" >> /opt/vmsetup.log