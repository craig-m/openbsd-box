#!/bin/ksh

# this script is run one time by packer (as root),
# before the machine is exported and saved as a box.

echo "OpenBSD setup.sh setup script"
sleep 10

set -e
set -x


# create /opt/ for non-standard things.
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


# login window
cp /etc/X11/xenodm/Xsetup_0 /etc/X11/xenodm/.Xsetup_0.bak


# create .Xresources
cat <<EOF > /home/puffy/.Xresources
XTerm*faceName:Terminus*
XTerm*faceSize:14
EOF

chown puffy:puffy /home/puffy/.Xresources


# install some packages into base box
pkg_add -uUv
pkg_add -I \
    dmidecode \
    curl \
    rsync-- \
    dos2unix \
    mutt--


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
sed -i -e "s/.*PermitRootLogin.*/PermitRootLogin yes/g" /etc/ssh/sshd_config

# Add insecure vagrant key
# https://github.com/hashicorp/vagrant/tree/main/keys
echo "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key" >> /home/puffy/.ssh/authorized_keys


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
