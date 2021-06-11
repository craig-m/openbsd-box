#!/bin/ksh

# run by Packer post-processor, and on Vagrant on provision/up.

echo "Testing script"
sleep 10

set -e
set -x

# check if setup.sh finished
if test -e /opt/.setup.sh; then
    echo '/opt exists (setup.sh ran)'
else
    echo 'ERROR setup.sh did not finish.'
    exit 1
fi

pkg_check

# test services ok
/etc/rc.d/ntpd check
/etc/rc.d/sshd check
/etc/rc.d/cron check
/etc/rc.d/xenodm check

# wait if rc.firsttime exists
while test -e /etc/rc.firsttime; do
    sleep 3
done
echo '/etc/rc.firsttime GONE'

sleep 10
echo "test.sh finished"