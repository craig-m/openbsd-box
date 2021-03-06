#!/bin/bash

echo "[*] cleaning up"
# note: will not remove openbsd install iso from packer_cache

vagrant destroy -f
vagrant box remove openbsd -f

rm -rfv -- output-openbsd-*
rm -f boxes/manifest.json
rm -f boxes/manifest.json.lock
rm -f boxes/OpenBSD.box
rm -f -- boxes/openbsd-*
rm -f packer.log

echo "[*] clean finished"