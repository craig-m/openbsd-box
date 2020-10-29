#!/bin/ksh

echo "OpenBSD setup.sh setup script"
sleep 3

set -e
set -x

# put all custom stuff under /opt
if test -d /opt; then
    echo "/opt already exists"
else
    echo "creating /opt"
    mkdir /opt
    chmod 770 /opt
    touch -f /opt/vmsetup.log
    echo "starting setup.sh" > /opt/vmsetup.log
fi


# X11 config
echo "machdep.allowaperture=2" >> /etc/sysctl.conf
echo "xenodm_flags=" >> /etc/rc.conf.local


pkg_add -uUv

# install some packages into base box
pkg_add -I \
    dmidecode \
    curl \
    vim--no_x11 \
    rsync-- \
    dos2unix


# install sudo
pkg_add sudo--
mkdir /etc/sudoers.d

cat <<EOF > /etc/sudoers
#includedir /etc/sudoers.d
EOF

# puffy user can sudo without password
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

# allow root ssh login
sed -i -e "s/.*PermitRootLogin.*/PermitRootLogin yes/g" /etc/ssh/sshd_config

sleep 3
sync

thetime=$(date +"%b %e %H:%M:%S")
echo "${thetime} setup.sh finished" >> /opt/vmsetup.log
