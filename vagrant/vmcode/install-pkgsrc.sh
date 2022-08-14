#!/bin/ksh

# https://www.pkgsrc.org/
# https://wiki.netbsd.org/pkgsrc/
# https://en.wikipedia.org/wiki/Pkgsrc

set -e
set -x

pkgsrc_download="pkgsrc-2022Q2.tar.xz"
pkgsrc_tar_sha="470239000812423ced0d183c8ac2b63c68c5ae35"

pkg_src_ver=${pkgsrc_download##pkgsrc-}
pkg_src_ver=${pkg_src_ver%%.tar.xz}

echo "Installing Pkgsrc $pkg_src_ver"


bmake_inst(){
    bmake
    bmake test
    bmake install
}


# get pkgsrc if missing
if test -e "$HOME/$pkgsrc_download"; then
    echo "have $pkgsrc_download already: "
else
    echo "Missing. Will download pkgsrc snapshot."
    cd $HOME
    ftp https://cdn.netbsd.org/pub/pkgsrc/stable/$pkgsrc_download
    pkgsrc_tar_sha_got=$(sha1 $pkgsrc_download | awk '{ print $4 }')
    if [ "$pkgsrc_tar_sha_got" == "$pkgsrc_tar_sha" ]; then
        echo "checksum OK:  $pkgsrc_tar_sha_got"
    else
        echo 'BAD checksum'
        echo "expect:  $pkgsrc_tar_sha"
        echo "we got:  $pkgsrc_tar_sha_got"
        exit 1
    fi
fi
ls -lah -- $HOME/$pkgsrc_download


# uncrompress
if test -e $HOME/pkgsrc/; then
    echo 'exists'
else
    echo 'untar'
    cd $HOME
    xz --decompres $HOME/$pkgsrc_download
    pkgsrc_download_tar=${pkgsrc_download%%.xz}
    tar -xf $pkgsrc_download_tar
fi


# run bootstrap scripts
if test -e $HOME/pkgsrc/bootstrap/built.txt; then
    echo 'installed'
else
    cd $HOME/pkgsrc/bootstrap
    ./bootstrap --unprivileged
    $HOME/pkg/sbin/pkg_admin -K $HOME/pkg/pkgdb fetch-pkg-vulnerabilities
    touch $HOME/pkgsrc/bootstrap/built.txt
fi


# install 'less' with pkgsrc
if test -e $HOME/pkg/bin/less; then
    echo 'compiled less already'
else
    echo 'installing less'
    cd $HOME/pkgsrc/misc/less/
    PATH=$PATH:$HOME/pkg/bin
    bmake_inst
fi