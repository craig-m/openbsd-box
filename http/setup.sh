#!/bin/sh

echo "OpenBSD setup.sh setup script"
sleep 1s

set -e
set -x

# filestore

mkdir /opt
chmod 770 /opt
touch -f /opt/vmsetup.log

# sudo

pkg_add sudo--
mkdir /etc/sudoers.d

cat <<EOF > /etc/sudoers
#includedir /etc/sudoers.d
EOF

cat <<EOF > /etc/sudoers.d/puffy
Defaults:puffy !requiretty
puffy ALL=(ALL) NOPASSWD: ALL
EOF

cat <<EOF > /etc/sudoers.d/root
Defaults:root !requiretty
root ALL=(ALL) NOPASSWD: ALL
EOF

chmod 440 /etc/sudoers.d/root
chmod 440 /etc/sudoers.d/puffy

# user files

chmod 750 /home/puffy
chown puffy:puffy /opt

sed -i -e "s/.*PermitRootLogin.*/PermitRootLogin yes/g" /etc/ssh/sshd_config

thetime=$(date +"%b %e %H:%M:%S")
echo "${thetime} setup.sh finished" >> /opt/vmsetup.log
