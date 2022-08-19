#!/bin/ksh

echo "packer.sh running" | logger

while pgrep -f reorder_kernel; do
    echo "wait for reorder_kernel";
    sleep 5;
done

dd if=/dev/zero of=/EMPTY bs=1M || true
rm -vf /EMPTY
sync

echo "packer.sh finished" | logger
