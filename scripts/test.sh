#!/bin/ksh

echo "Testing script"
sleep 10

set -e
set -x

# check if we created /opt yet
if test -d /opt; then
    echo '/opt exists (setup.sh ran)'
else
    echo 'ERROR /opt not created'
    exit 1
fi

pkg_check

if test -e /etc/rc.firsttime; then
    echo '/etc/rc.firsttime exists'
    sleep 60
else
    echo '/etc/rc.firsttime GONE'
fi

sleep 10
echo "test.sh finished"
