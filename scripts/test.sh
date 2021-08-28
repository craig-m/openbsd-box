#!/bin/ksh

# run by Packer post-processor, and on Vagrant on provision/up.

echo "Testing script"

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


# test services are running
check_service(){
    for p in $*
    do
        /etc/rc.d/$p check || { echo "ERROR: $p not running"; exit 1; }
        pgrep $p
    done
}

check_service sshd ntpd cron smtpd pflogd xenodm


# check for installed packages
check_pkginst(){

    check_pkginst_fail(){
        echo "ERROR: missing $1"
        logger "ERROR: test.sh could not find $1"
        exit 1
    }

    for b in $*
    do
        test -x /usr/local/bin/$b && ls -lah -- /usr/local/bin/$b || check_pkginst_fail $b
    done
}

check_pkginst rsync curl xz vim git


# wait if rc.firsttime exists
while test -e /etc/rc.firsttime; do
    sleep 3
done
echo '/etc/rc.firsttime GONE'


# done
echo "test.sh finished"