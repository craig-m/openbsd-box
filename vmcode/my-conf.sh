#!/bin/ksh


#
# pf firewall
#

if test -e /etc/pf.conf.bak; then
    echo 'pf.conf backup exists'
else
    echo 'creating pf.conf backup'
    cp /etc/pf.conf /etc/pf.conf.bak
fi

