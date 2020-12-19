#!/bin/ksh

# this script is run one time by packer (as root),
# before the machine is exported and saved as a box.

echo "OpenBSD setup.sh setup script"
sleep 10

set -e
set -x

# put all custom stuff under /opt
if test -d /opt; then
    echo "/opt already exists"
else
    echo "creating /opt"
    mkdir /opt
    chmod 770 /opt
    chown puffy:puffy /opt
    touch -f /opt/vmsetup.log
    echo "setup.sh starting" > /opt/vmsetup.log
fi


# X11 config
cp /etc/sysctl.conf /etc/.sysctl.conf.bak
echo "machdep.allowaperture=2" >> /etc/sysctl.conf
echo "xenodm_flags=" >> /etc/rc.conf.local


pkg_add -uUv

# install some packages into base box
pkg_add -I \
    dmidecode \
    curl \
    vim--no_x11 \
    rsync-- \
    dos2unix \
    mutt-- \
    openbsd-backgrounds

# login window
cp /etc/X11/xenodm/Xsetup_0 /etc/X11/xenodm/.Xsetup_0.bak
cat <<EOF > /etc/X11/xenodm/Xsetup_0
#!/bin/sh
if test -x /usr/local/bin/openbsd-wallpaper
then
    /usr/local/bin/openbsd-wallpaper
fi
EOF

# create .Xresources
cat <<EOF > /home/puffy/.Xresources
XTerm*faceName:Terminus*
XTerm*faceSize:14
EOF

chown puffy:puffy /home/puffy/.Xresources


# install sudo (used by Vagrant)
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


# tighten homedir perm
chmod 750 /home/puffy

# allow root ssh login
#sed -i -e "s/.*PermitRootLogin.*/PermitRootLogin yes/g" /etc/ssh/sshd_config


# update/patch script

cat <<EOF > /root/update.sh
#!/bin/ksh
echo "patching system"

# update packages
pkg_add -uUv

# update firmware
fw_update

# patch OpenBSD
syspatch

# Upgrade to next release of OpenBSD
#sysupgrade
#sysmerge

echo "patching finished"
EOF

chmod +x /root/update.sh


sleep 10
sync

echo "setup.sh finished" >> /opt/vmsetup.log
logger "setup.sh finished"
