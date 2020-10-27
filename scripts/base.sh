#!/bin/ksh

# this script is run by Packer

echo "OpenBSD base.sh setup script"

set -e
set -x

# info
uname -a
pwd

sleep 3


# check if we created /opt yet
if test -d /opt; then
    echo '/opt exists (setup.sh ran)'
else
    echo 'ERROR /opt not created'
    exit 1
fi

# box info
if test -e /opt/box_info.txt; then
    echo '/opt/box_info.txt exists already'
else
    touch -f /opt/box_info.txt
    echo "--- OpenBSD box info ---" >> /opt/box_info.txt
    echo $PACKER_BUILD_NAME >> /opt/box_info.txt
    echo $MY_BOX_VER >> /opt/box_info.txt
    echo $MY_ISO_URL >> /opt/box_info.txt
    echo $MY_ISO_SUM >> /opt/box_info.txt
fi


# stop mail server (why is this even installed by default)
rcctl stop smtpd
rcctl disable smtpd

# disable sound
rcctl stop sndiod
rcctl disable sndiod


if test -e /etc/rc.firsttime; then
    echo '/etc/rc.firsttime exists'
    sleep 60
else
    echo '/etc/rc.firsttime GONE'
fi

sync

# done
thetime=$(date +"%b %e %H:%M:%S")
echo "${thetime} base.sh finished" >> /opt/vmsetup.log
