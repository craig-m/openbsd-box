#!/usr/bin/env  sh

echo "[*] Building and starting OpenBSD box."

# do not use root
if [ root = "$USER" ]; then
  echo "Error: do not run as root";
  exit 1;
fi


# script input flags
case "$1" in
  "-qu")
    echo "[*] packer QEMU build"
    packbldtype="qemu.openbsd-qu"
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
cd packer/ || exit 1

 packer init -upgrade ${packerinput}

# Validate packer input
packer validate -syntax-only ${packerinput} || { echo "ERROR validating ${packerinput}"; exit 1; }

# Build the box
packer build -only=${packbldtype} ${packerinput} || { echo "ERROR packer build failed"; exit 1; }

# list build files
echo "------ box files ------"
ls -lah -- boxes/

# add box to local vagrant cache
vagrant box add boxes/OpenBSD.box --force --name OpenBSD.box || { echo "ERROR vagrant add box"; exit 1; }

cd ..


#
# Vagrant
#
cd vagrant/ || exit 1

# Validate Vagrantfile
vagrant validate Vagrantfile || { echo "ERROR in Vagrantfile"; exit 1; }

# Start vagrant VM
echo "[*] starting VM"
vagrant status | grep "not created" -q || { echo "ERROR created already"; exit 1; }


case "$1" in
  "-qu")
    # QEMU
    echo "start with: "
    echo "vagrant up --provider=libvirt"
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

cd ..

echo -e "\n[*] Finished build script."