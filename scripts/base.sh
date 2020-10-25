#!/bin/ksh
echo "OpenBSD base.sh setup script"

set -e
set -x

# info
uname -a

sleep 3


# check if we created /opt yet
if test -d /opt; then
    echo '/opt exists (setup.sh ran)'
else
    echo 'ERROR /opt not created'
    exit 1
fi

# stop mail server (why is this even installed by default)
rcctl stop smtpd
rcctl disable smtpd

# disable sound
rcctl stop sndiod
rcctl disable sndiod

# install some packages
pkg_add -uUv
pkg_add -I dmidecode curl vim--no_x11 rsync-- dos2unix


# X11 config
echo "machdep.allowaperture=2" >> /etc/sysctl.conf
echo "xenodm_flags=" >> /etc/rc.conf.local


sleep 5
sync

if test -e /etc/rc.firsttime; then
    echo '/etc/rc.firsttime exists'
else
    echo '/etc/rc.firsttime GONE'
fi


# done
thetime=$(date +"%b %e %H:%M:%S")
echo "${thetime} base.sh finished" >> /opt/vmsetup.log
