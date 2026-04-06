#!/usr/bin/env  sh

echo "[*] Starting OpenBSD VM from a build."

# do not use root
if [ root = "$USER" ]; then
  echo "Error: do not run as root";
  exit 1;
fi


# script input flags
case "$1" in
  "-qu")
    echo "[*] QEMU provider"
    ;;
  "-vb")
    echo "[*] VirtualBox provider"
    ;;
  *)
    echo "[.] ERROR failed to select type. Please select 1 of:"
    echo ""
    echo "VirtualBox    -vb"
    echo "QEMU          -qu"
    echo ""
    echo "example:  ./run.sh -vb"
    echo "example:  ./run.sh -vb v7.1_b001_20240101_120000"
    exit 1
    ;;
esac


# Select build: use provided BUILD_ID or default to latest
if [ -n "$2" ]; then
  BUILD_ID="$2"
  echo "[*] Using specified build: ${BUILD_ID}"
else
  if [ ! -d "builds" ] || [ -z "$(ls -A builds 2>/dev/null)" ]; then
    echo "[.] ERROR: No builds found in builds/. Run build.sh first."
    exit 1
  fi
  BUILD_ID=$(ls -1t builds/ | head -n 1)
  echo "[*] Using latest build: ${BUILD_ID}"
fi

BUILD_DIR="builds/${BUILD_ID}"

if [ ! -f "${BUILD_DIR}/OpenBSD.box" ]; then
  echo "[.] ERROR: Box not found at ${BUILD_DIR}/OpenBSD.box"
  echo "[.] Available builds:"
  ls -1t builds/ 2>/dev/null || echo "  (none)"
  exit 1
fi


#
# Vagrant
#

# add box to local vagrant cache
vagrant box add "${BUILD_DIR}/OpenBSD.box" --force --name OpenBSD.box || { echo "ERROR vagrant add box"; exit 1; }

cd vagrant/ || exit 1

# Validate Vagrantfile
vagrant validate Vagrantfile || { echo "ERROR: Vagrantfile validation failed"; exit 1; }

# Start vagrant VM
echo "[*] starting VM"
vagrant status | grep "not created" -q || { echo "ERROR: VM already exists. Destroy it first with: vagrant destroy"; exit 1; }


case "$1" in
  "-qu")
    # QEMU
    echo "start with: "
    echo "vagrant up --provider=libvirt"
    ;;
  "-vb")
    # Virtual Box
    vagrant up --provider=virtualbox
    vagrant ssh --command "uptime" --machine-readable || { echo "ERROR: Failed to SSH into VM"; exit 1; }
    echo "[*] Started VM on Virtual Box"
    ;;
  *)
    echo "[.] ERROR failed to select type."
    exit 1
    ;;
esac

cd ..

echo -e "\n[*] Finished run script."
