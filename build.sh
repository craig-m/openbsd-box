#!/bin/bash
echo "[*] Building OpenBSD box."

# script input flags
case "$1" in
  "-hv")
    packbldtype="openbsd-hv"
    echo "[*] packer HyperV build"
    ;;
  "-qu")
    packbldtype="openbsd-qu"
    echo "[*] packer QEMU build"
    ;;
  "-vw")
    packbldtype="openbsd-vw"
    echo "[*] packer VMWare build"
    ;;
  "-vb")
    packbldtype="openbsd-vb"
    echo "[*] packer VirtualBox build"
    ;;
  *)
    packbldtype=""
    echo "[.] ERROR failed to select type. Please select 1 of:"
    echo ""
    echo "VirtualBox    -vb"
    echo "Hyper-V       -hv"
    echo "VMWare        -vw"
    echo "QEMU          -qu"
    echo ""
    echo "example:  ./build.sh -vb"
    exit 1
    ;;
esac

# vars
packerinput="openbsd.json"
#packerinput="openbsd.json.pkr.hcl"

export PACKER_LOG=2
export PACKER_LOG_PATH=packer.log

echo "[*] using config: ${packerinput}"

# Validate packer input
packer validate -syntax-only ${packerinput} || { echo "ERROR validating ${packerinput}"; exit 1; }

# Build the box
packer build -only=${packbldtype} ${packerinput} || { echo "ERROR packer build failed"; exit 1; }

echo "------ box files ------"
ls -lah -- boxes/

# Start vagrant VM
vagrant status | grep "not created" -q || { echo "ERROR created already"; exit 1; }

case "$1" in
  "-hv")
    vagrant up --provider=hyperv
    ;;
  "-qu")
    #vagrant up --provider=libvirt
    ;;
  "-vw")
    vagrant up
    ;;
  "-vb")
    vagrant up --provider=virtualbox
    ;;
  *)
    packbldtype=""
    echo "[.] ERROR failed to select type."
    exit 1
    ;;
esac

echo "[*] Finished build script."