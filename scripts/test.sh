#!/bin/ksh

echo "Testing script"
sleep 3

set -e
set -x

ls -la /opt/vmsetup.log

pkg_check

if test -e /etc/rc.firsttime; then
    echo '/etc/rc.firsttime exists'
    sleep 60
else
    echo '/etc/rc.firsttime GONE'
fi

thetime=$(date +"%b %e %H:%M:%S")
echo "${thetime} test.sh finished" >> /opt/vmsetup.log
