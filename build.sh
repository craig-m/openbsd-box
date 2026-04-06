#!/usr/bin/env  sh

echo "[*] Building OpenBSD box."

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
export PKR_VAR_version="v7.1_b001"

# Generate a unique build ID and output directory
BUILD_ID="${PKR_VAR_version}_$(date +%Y%m%d_%H%M%S)"
BUILD_DIR="builds/${BUILD_ID}"
mkdir -p "${BUILD_DIR}"

export PACKER_LOG_PATH="${BUILD_DIR}/packer.log"
export PKR_VAR_output_dir="../${BUILD_DIR}"

echo "[*] using config: ${packerinput}"
echo "[*] build ID: ${BUILD_ID}"
echo "[*] output dir: ${BUILD_DIR}"


#
# Packer
#
cd packer/ || exit 1

 packer init -upgrade ${packerinput}

# Validate packer input
packer validate -syntax-only ${packerinput} || { echo "ERROR validating ${packerinput}"; exit 1; }

# Build the box
packer build -only=${packbldtype} ${packerinput} || { echo "ERROR packer build failed"; exit 1; }

cd ..

# list build files
echo "------ box files ------"
ls -lah -- "${BUILD_DIR}/"

echo ""
echo "[*] Build complete. Box stored in: ${BUILD_DIR}"
echo "[*] To start the VM run: ./run.sh $1 ${BUILD_ID}"
echo ""
echo -e "\n[*] Finished build script."
