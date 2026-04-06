#!/usr/bin/env sh

echo "[*] cleaning up"

if [ root = "$USER" ]; then
  echo "Error: do not run as root";
  exit 1;
fi

cd vagrant
vagrant destroy -f
vagrant box remove OpenBSD.box -f
cd ../

cd packer/
rm -rfv -- output-openbsd-*
rm -fv packer.log
cd ..

rm -rfv -- builds/

echo "[*] clean finished"