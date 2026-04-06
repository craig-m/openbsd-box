#!/usr/bin/env sh

echo "[*] cleaning up"

if [ root = "$USER" ]; then
  echo "Error: do not run as root";
  exit 1;
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

cd "${SCRIPT_DIR}/vagrant" || exit 1
vagrant destroy -f
vagrant box remove OpenBSD.box -f || true
cd "${SCRIPT_DIR}"

cd "${SCRIPT_DIR}/packer/"
rm -rfv -- output-openbsd-*
rm -fv packer.log
cd "${SCRIPT_DIR}"

rm -rfv -- "${SCRIPT_DIR}/builds/"

echo "[*] clean finished"