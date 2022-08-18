#!/bin/env sh

# note: will not remove openbsd install iso from packer_cache

echo "[*] cleaning up"

if [[ root = "$USER" ]]; then
  echo "Error: do not run as root";
  exit 1;
fi

cd vagrant
vagrant destroy -f
vagrant box remove OpenBSD.box -f
cd ../

cd packer/
rm -rfv -- output-openbsd-*
rm -fv boxes/manifest.json
rm -fv boxes/manifest.json.lock
rm -fv boxes/OpenBSD.box
rm -fv -- boxes/openbsd-*
rm -fv packer.log
cd ..

echo "[*] clean finished"