#!/bin/ksh

echo "copying config"

set -e
set -x


#
# pf firewall
#

if test -e /etc/.pf.conf.bak; then
    echo 'pf.conf backup exists'
else
    echo 'creating pf.conf backup'
    cp /etc/pf.conf /etc/.pf.conf.bak
fi

cp /opt/vmcode/my-etc/pf.conf /etc/pf.conf

# test rules
pfctl -n -f /etc/pf.conf
# load rules
pfctl -f /etc/pf.conf


#
# httpd webserver
#

cp /opt/vmcode/my-etc/httpd.conf /etc/httpd.conf

mkdir -p /var/www/htdocs/{local,pub}/
touch -f /var/www/htdocs/{local,pub}/index.html
echo "hello" > /var/www/htdocs/local/index.html
echo "public" > /var/www/htdocs/pub/index.html

# check config
httpd -n

rcctl enable httpd
rcctl start httpd


echo "config script finished"