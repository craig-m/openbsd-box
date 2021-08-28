#!/bin/bash

echo "[*] cleaning up"
# note: will not remove openbsd install iso from packer_cache

if [[ root = "$USER" ]]; then
  echo "Error: do not run as root";
  exit 1;
fi

vagrant destroy -f
vagrant box remove openbsd -f

rm -rfv -- output-openbsd-*
rm -fv boxes/manifest.json
rm -fv boxes/manifest.json.lock
rm -fv boxes/OpenBSD.box
rm -fv -- boxes/openbsd-*
rm -fv packer.log

echo "[*] clean finished"