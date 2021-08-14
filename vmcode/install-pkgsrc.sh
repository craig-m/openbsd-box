#!/bin/ksh

# https://www.pkgsrc.org/
# https://wiki.netbsd.org/pkgsrc/

cd ~/

CVS_RSH=ssh cvs -danoncvs@anoncvs.NetBSD.org:/cvsroot checkout -r pkgsrc-2021Q2 -P pkgsrc

cd pkgsrc/bootstrap

./bootstrap --unprivileged
