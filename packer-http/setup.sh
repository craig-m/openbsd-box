#!/bin/ksh

# this script is run one time by packer (as root),
# before the machine is exported and saved as a box.

echo "OpenBSD setup.sh setup script"
sleep 5

set -e
set -x

newuser="puffy"

# create /opt/ for non-standard things.
if test -d /opt; then
    echo "/opt already exists"
else
    echo "creating /opt"
    mkdir /opt
    chmod 770 /opt
    chown ${newuser}:${newuser} /opt
    touch -f /opt/vmsetup.log
    echo "setup.sh starting" > /opt/vmsetup.log
fi


# X11 config
cp /etc/sysctl.conf /etc/.sysctl.conf.bak
echo "machdep.allowaperture=2" >> /etc/sysctl.conf
echo "xenodm_flags=" >> /etc/rc.conf.local


# login window
cp /etc/X11/xenodm/Xsetup_0 /etc/X11/xenodm/.Xsetup_0.bak

# shell prompt
echo 'export PS1="\u@\H \W \$ "' >> /root/.profile
echo 'export PS1="\u@\H \W \$ "' >> /home/${newuser}/.profile

# create .Xresources
cat <<EOF > /home/${newuser}/.Xresources
XTerm*faceName:Terminus*
XTerm*faceSize:14
EOF

touch /home/${newuser}/.hushlogin
mkdir /home/${newuser}/bin/

chown -R ${newuser}:${newuser} /home/${newuser}/*


# install some packages into base box
# https://www.openbsd.org/faq/faq15.html
pkg_add -uUv
pkg_add -I \
    dmidecode \
    curl \
    rsync-- \
    dos2unix \
    vim--no_x11 \
    mutt-- \
    xz

# allow user to become root
echo "permit nopass ${newuser}" >> /etc/doas.conf

# tighten homedir perm
#chmod 750 /home/${newuser}

# allow root ssh login
# sed -i -e "s/.*PermitRootLogin.*/PermitRootLogin yes/g" /etc/ssh/sshd_config

# Add insecure default vagrant key - https://github.com/hashicorp/vagrant/tree/main/keys
echo "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key" >> /home/${newuser}/.ssh/authorized_keys


# create update/patch script
# packer will run this later
cat <<EOF > /opt/update.sh
#!/bin/ksh
logger "update.sh started"
echo "update.sh started" >> /opt/vmsetup.log

# wait if rc.firsttime exists
while test -e /etc/rc.firsttime; do
    sleep 10
done

# wait if /opt/.setup.sh does NOT exist
while test ! -e /opt/.setup.sh; do
    sleep 10
done

# update packages
pkg_add -uUv

# update firmware
fw_update

# patch OpenBSD
syspatch

sleep 3
sync

logger "update.sh finished"
echo "update.sh finished" >> /opt/vmsetup.log
EOF

chmod +x /opt/update.sh

touch /opt/.setup.sh
echo "setup.sh finished" >> /opt/vmsetup.log
logger "setup.sh finished"

# Finished
sleep 5
sync