#!/bin/ksh

echo "packer.sh running" | logger

dd if=/dev/zero of=/EMPTY bs=1M || true
rm -vf /EMPTY
sync

echo "packer.sh finished" | logger
