#!/usr/bin/env sh

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
    echo "Usage:  ./build.sh -vb [-V <version>]"
    echo "        ./build.sh -qu [-V <version>]"
    echo ""
    echo "Example:  ./build.sh -vb"
    echo "          ./build.sh -vb -V 7.6"
    echo ""
    echo "Supported versions: 7.0 7.1 7.2 7.3 7.4 7.5 7.6 7.7 7.8"
    echo ""
    exit 1
    ;;
esac


# Parse optional version flag (-V <version>)
OBSD_VERSION=""
shift
while [ $# -gt 0 ]; do
  case "$1" in
    "-V")
      shift
      OBSD_VERSION="$1"
      ;;
    *)
      echo "[.] Unknown option: $1"
      exit 1
      ;;
  esac
  shift
done


# Load version definitions
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
VERSIONS_CONF="${SCRIPT_DIR}/packer/versions.conf"
if [ ! -f "${VERSIONS_CONF}" ]; then
  echo "[.] ERROR: versions.conf not found at ${VERSIONS_CONF}"
  exit 1
fi
# shellcheck source=packer/versions.conf
. "${VERSIONS_CONF}"

# Select version (default to latest)
if [ -z "${OBSD_VERSION}" ]; then
  OBSD_VERSION="${OPENBSD_DEFAULT_VERSION}"
  echo "[*] No version specified, using default: ${OBSD_VERSION}"
fi

# Resolve ISO URL and checksum from versions.conf
VER_KEY=$(printf '%s' "${OBSD_VERSION}" | tr -d '.')
ISO_URL_VAR="ISO_URL_${VER_KEY}"
ISO_SHA256_VAR="ISO_SHA256_${VER_KEY}"

eval "RESOLVED_ISO_URL=\${${ISO_URL_VAR}}"
eval "RESOLVED_ISO_SHA256=\${${ISO_SHA256_VAR}}"

if [ -z "${RESOLVED_ISO_URL}" ] || [ -z "${RESOLVED_ISO_SHA256}" ]; then
  echo "[.] ERROR: Unknown OpenBSD version '${OBSD_VERSION}'."
  echo "    Supported versions: ${OPENBSD_SUPPORTED_VERSIONS}"
  exit 1
fi

# Guard against placeholder checksums
case "${RESOLVED_ISO_SHA256}" in
  VERIFY_FROM_*)
    echo "[.] ERROR: Checksum for OpenBSD ${OBSD_VERSION} has not been set."
    echo "    Edit packer/versions.conf and fill in the SHA256 checksum"
    echo "    from https://mirrors.openbsd.org/pub/OpenBSD/${OBSD_VERSION}/amd64/SHA256"
    exit 1
    ;;
esac

echo "[*] OpenBSD version: ${OBSD_VERSION}"
echo "[*] ISO URL: ${RESOLVED_ISO_URL}"


# vars
packerinput="openbsd.pkr.hcl"

export PACKER_LOG=3
export PKR_VAR_version="v${OBSD_VERSION}_b001"
export PKR_VAR_iso_url="${RESOLVED_ISO_URL}"
export PKR_VAR_iso_checksum="${RESOLVED_ISO_SHA256}"

# Generate a unique build ID and output directory
BUILD_ID="${PKR_VAR_version}_$(date +%Y%m%d_%H%M%S)"
BUILD_DIR="builds/${BUILD_ID}"
mkdir -p "${SCRIPT_DIR}/${BUILD_DIR}"

# Serial console log goes into the build directory (captured on the host)
SERIAL_LOG_PATH="${SCRIPT_DIR}/${BUILD_DIR}/serial.log"
export PKR_VAR_vm_serial_log="${SERIAL_LOG_PATH}"

export PACKER_LOG_PATH="${SCRIPT_DIR}/${BUILD_DIR}/packer.log"
export PKR_VAR_output_dir="../${BUILD_DIR}"

echo "[*] using config: ${packerinput}"
echo "[*] build ID: ${BUILD_ID}"
echo "[*] output dir: ${BUILD_DIR}"
echo "[*] serial log: ${SERIAL_LOG_PATH}"


#
# Packer
#
cd "${SCRIPT_DIR}/packer/" || exit 1

packer init -upgrade ${packerinput}

# Validate packer input
packer validate -syntax-only ${packerinput} || { echo "ERROR validating ${packerinput}"; exit 1; }

# Build the box
packer build -only=${packbldtype} ${packerinput} || { echo "ERROR packer build failed"; exit 1; }

cd "${SCRIPT_DIR}"

# list build files
echo "------ box files ------"
ls -lah -- "${BUILD_DIR}/"

echo ""
echo "[*] Build complete. Box stored in: ${BUILD_DIR}"
echo "[*] To start the VM run: ./run.sh -vb ${BUILD_ID}"
if [ -f "${SERIAL_LOG_PATH}" ]; then
  echo "[*] Serial console log: ${SERIAL_LOG_PATH}"
fi
echo ""
echo "[*] Finished build script."
