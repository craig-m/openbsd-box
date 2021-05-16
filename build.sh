#!/bin/bash
echo "Building OpenBSD box."

# script input flags
case "$1" in
  "-hv")
    packbldtype="openbsd-hv"
    echo "packer HyperV build"
    ;;
  "-qu")
    packbldtype="openbsd-qu"
    echo "packer QEMU build"
    ;;
  "-vw")
    packbldtype="openbsd-vw"
    echo "packer VMWare build"
    ;;
  "-vb")
    packbldtype="openbsd-vb"
    echo "packer VirtualBox build"
    ;;
  *)
    packbldtype=""
    echo "ERROR failed to select type. Please select 1 of:"
    echo ""
    echo "VirtualBox    -vb"
    echo "HyperV        -hv"
    echo "VMWare        -vw"
    echo "QEMU          -qu"
    echo ""
    echo "example:  ./build.sh -vb"
    exit 1
    ;;
esac

# vars
packerinput="openbsd.json"
#packerinput="openbsd.pkr.hcl"
export PACKER_LOG=1

echo "using config: ${packerinput}"

# Validate
packer validate -syntax-only ${packerinput} || { echo "ERROR validating ${packerinput}"; exit 1; }

# Build
packer build -only=${packbldtype} ${packerinput}

# Start vagrant VM
vagrant status | grep "not created" -q || { echo "ERROR created already"; exit 1; }
vagrant up

echo "Finished build script."