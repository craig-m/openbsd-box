#!/bin/ksh

# https://www.pkgsrc.org/
# https://wiki.netbsd.org/pkgsrc/
# https://en.wikipedia.org/wiki/Pkgsrc

cd ~/

if test -e pkgsrc.tar; then
    echo 'have pkgsrc.tar.xz already'
else
    ftp https://cdn.netbsd.org/pub/pkgsrc/stable/pkgsrc.tar.xz
fi

if test -e pkgsrc/; then
    echo 'exists'
else
    echo 'untar'
    xz --decompress pkgsrc.tar.xz
    tar -xf pkgsrc.tar
fi

cd pkgsrc/bootstrap

if test -e built.txt; then
    echo 'installed'
else
    ./bootstrap --unprivileged
    ~/pkg/sbin/pkg_admin -K ~/pkg/pkgdb fetch-pkg-vulnerabilities
    touch built.txt
fi

if test -e ~/pkg/bin/less; then
    echo 'compiled'
else
    PATH=$PATH:$HOME/pkg/bin
    cd ~/pkgsrc/misc/less/
    bmake
    bmake test
    bmake install
fi