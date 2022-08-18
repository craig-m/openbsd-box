#!/bin/env sh

echo "[*] Building and starting OpenBSD box."

# do not use root
if [[ root = "$USER" ]]; then
  echo "Error: do not run as root";
  exit 1;
fi


# script input flags
case "$1" in
  "-hv")
    echo "[*] packer HyperV build"
    packbldtype="hyperv-iso.openbsd-hv"
    ;;
  "-qu")
    echo "[*] packer QEMU build"
    packbldtype="qemu.openbsd-qu"
    ;;
  "-vw")
    echo "[*] packer VMWare build"
    packbldtype="vmware-iso.openbsd-vw"
    ;;
  "-vb")
    echo "[*] packer VirtualBox build"
    packbldtype="virtualbox-iso.openbsd-vb"
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
packerinput="openbsd.pkr.hcl"

export PACKER_LOG=3
export PACKER_LOG_PATH=packer.log
export PKR_VAR_version="v7.1_b001"

echo "[*] using config: ${packerinput}"


#
# Packer
#
pushd packer/

# Validate packer input
packer validate -syntax-only ${packerinput} || { echo "ERROR validating ${packerinput}"; exit 1; }

# Build the box
packer build -only=${packbldtype} ${packerinput} || { echo "ERROR packer build failed"; exit 1; }

# list build files
echo "------ box files ------"
ls -lah -- boxes/

# add box to local vagrant cache
vagrant box add boxes/OpenBSD.box --name OpenBSD.box || { echo "ERROR vagrant add box"; exit 1; }

popd


#
# Vagrant
#
pushd vagrant/

# Validate Vagrantfile
vagrant validate Vagrantfile || { echo "ERROR in Vagrantfile"; exit 1; }

# Start vagrant VM
echo "[*] starting VM"
vagrant status | grep "not created" -q || { echo "ERROR created already"; exit 1; }


case "$1" in
  "-hv")
    # Hyper-V
    vagrant up --provider=hyperv
    vagrant ssh --command "uptime" --machine-readable || { echo "ERROR starting VM"; exit 1; }
    echo "[*] Started VM on Hyper-V"
    ;;
  "-qu")
    # QEMU
    echo "start with: "
    echo "vagrant up --provider=libvirt"
    ;;
  "-vw")
    # VMWare
    vagrant up
    vagrant ssh --command "uptime" --machine-readable || { echo "ERROR starting VM"; exit 1; }
    echo "[*] Started VM on VMWare"
    ;;
  "-vb")
    # Virtual Box
    vagrant up --provider=virtualbox
    vagrant ssh --command "uptime" --machine-readable || { echo "ERROR starting VM"; exit 1; }
    echo "[*] Started VM on Virtual Box"
    ;;
  *)
    packbldtype=""
    echo "[.] ERROR failed to select type."
    exit 1
    ;;
esac

popd

echo -e "\n[*] Finished build script."