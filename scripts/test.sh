#!/bin/sh

echo "Testing script"
sleep 3

set -e
set -x

ls -la /opt/vmsetup.log

pkg_check

thetime=$(date +"%b %e %H:%M:%S")
echo "${thetime} test.sh finished" >> /opt/vmsetup.log
