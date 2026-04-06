#!/usr/bin/env sh
#
# setup-host.sh – install dependencies for openbsd-box on Ubuntu LTS
#
# Run once on your Linux host before using build.sh or run.sh.
# Tested on Ubuntu 22.04 LTS and 24.04 LTS.
#
# Usage:
#   sudo ./scripts/setup-host.sh           # install everything
#   sudo ./scripts/setup-host.sh --check   # check what is already installed

set -e

PACKER_VERSION="1.11.0"
VAGRANT_VERSION="2.4.1"

CHECK_ONLY=0
if [ "${1}" = "--check" ]; then
  CHECK_ONLY=1
fi

ok()   { printf "  [OK]  %s\n" "$1"; }
warn() { printf "  [!!]  %s\n" "$1"; }
info() { printf "  [..]  %s\n" "$1"; }

check_cmd() {
  if command -v "$1" >/dev/null 2>&1; then
    ok "$1 found: $(command -v "$1")"
    return 0
  else
    warn "$1 not found"
    return 1
  fi
}

echo ""
echo "=== openbsd-box host dependency check ==="
echo ""

# ── required tools ─────────────────────────────────────────────────────────

MISSING=""

check_cmd packer  || MISSING="${MISSING} packer"
check_cmd vagrant || MISSING="${MISSING} vagrant"
check_cmd qemu-system-x86_64 || MISSING="${MISSING} qemu-system-x86_64"
check_cmd VBoxManage || warn "VBoxManage not found (needed for -vb builds, optional if using QEMU)"
check_cmd git     || MISSING="${MISSING} git"
check_cmd curl    || MISSING="${MISSING} curl"
check_cmd sha256sum || MISSING="${MISSING} sha256sum"

echo ""

if [ "${CHECK_ONLY}" = "1" ]; then
  if [ -n "${MISSING}" ]; then
    warn "Missing tools:${MISSING}"
    echo "  Run without --check to install them."
    exit 1
  else
    ok "All required tools are present."
    exit 0
  fi
fi

# ── require root for install ────────────────────────────────────────────────

if [ "$(id -u)" != "0" ]; then
  echo "Error: installation requires root. Run: sudo $0"
  exit 1
fi

# ── detect distro ───────────────────────────────────────────────────────────

if [ ! -f /etc/os-release ]; then
  warn "Cannot detect OS. This script targets Ubuntu LTS."
  exit 1
fi
. /etc/os-release
info "Detected OS: ${PRETTY_NAME}"
case "${ID}" in
  ubuntu|debian) : ;;
  *)
    warn "This script is written for Ubuntu/Debian. Proceed with caution."
    ;;
esac

# ── system packages ─────────────────────────────────────────────────────────

info "Updating apt package index..."
apt-get update -qq

info "Installing base dependencies..."
apt-get install -y -qq \
  curl wget git unzip gnupg lsb-release \
  qemu-system-x86 qemu-utils libvirt-daemon-system libvirt-clients \
  virtinst bridge-utils cpu-checker \
  rsync

# ── Packer ─────────────────────────────────────────────────────────────────

if ! command -v packer >/dev/null 2>&1; then
  info "Installing Packer ${PACKER_VERSION}..."
  PACKER_URL="https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip"
  TMP_ZIP=$(mktemp /tmp/packer-XXXXXX.zip)
  curl -fsSL "${PACKER_URL}" -o "${TMP_ZIP}"
  unzip -o "${TMP_ZIP}" -d /usr/local/bin/
  rm -f "${TMP_ZIP}"
  ok "Packer installed: $(packer version)"
else
  ok "Packer already installed: $(packer version | head -1)"
fi

# ── Vagrant ─────────────────────────────────────────────────────────────────

if ! command -v vagrant >/dev/null 2>&1; then
  info "Installing Vagrant ${VAGRANT_VERSION}..."
  VAGRANT_URL="https://releases.hashicorp.com/vagrant/${VAGRANT_VERSION}/vagrant_${VAGRANT_VERSION}-1_amd64.deb"
  TMP_DEB=$(mktemp /tmp/vagrant-XXXXXX.deb)
  curl -fsSL "${VAGRANT_URL}" -o "${TMP_DEB}"
  dpkg -i "${TMP_DEB}"
  rm -f "${TMP_DEB}"
  ok "Vagrant installed: $(vagrant version | head -1)"
else
  ok "Vagrant already installed: $(vagrant version | head -1)"
fi

# ── vagrant-libvirt plugin ──────────────────────────────────────────────────

if ! vagrant plugin list 2>/dev/null | grep -q vagrant-libvirt; then
  info "Installing vagrant-libvirt plugin (needed for QEMU/KVM builds)..."
  # Install as the calling user, not root
  SUDO_USER="${SUDO_USER:-$(logname 2>/dev/null || echo "")}"
  if [ -n "${SUDO_USER}" ] && [ "${SUDO_USER}" != "root" ]; then
    su - "${SUDO_USER}" -c "vagrant plugin install vagrant-libvirt"
  else
    vagrant plugin install vagrant-libvirt
  fi
  ok "vagrant-libvirt installed"
else
  ok "vagrant-libvirt already installed"
fi

# ── KVM hardware acceleration check ────────────────────────────────────────

echo ""
info "Checking KVM hardware acceleration..."
if kvm-ok 2>/dev/null; then
  ok "KVM acceleration available"
else
  warn "KVM acceleration not available. QEMU builds will be slow."
  warn "Ensure nested virtualisation is enabled if running inside a VM."
fi

# ── user group membership ───────────────────────────────────────────────────

SUDO_USER="${SUDO_USER:-$(logname 2>/dev/null || echo "")}"
if [ -n "${SUDO_USER}" ] && [ "${SUDO_USER}" != "root" ]; then
  for GRP in libvirt kvm; do
    if getent group "${GRP}" >/dev/null 2>&1; then
      usermod -aG "${GRP}" "${SUDO_USER}" 2>/dev/null || true
      ok "Added ${SUDO_USER} to group ${GRP}"
    fi
  done
  warn "Log out and back in (or run 'newgrp libvirt') for group changes to take effect."
fi

echo ""
echo "=== Setup complete ==="
echo ""
echo "Next steps:"
echo "  1. ./build.sh -qu          # build with QEMU (recommended on Linux)"
echo "  2. ./build.sh -qu -V 7.6   # build a specific OpenBSD version"
echo "  3. ./run.sh -qu            # start the VM"
echo ""
