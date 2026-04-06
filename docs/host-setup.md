# Host Setup – Ubuntu LTS

This document describes how to prepare an Ubuntu LTS desktop or server to
build and run OpenBSD VMs with openbsd-box.

Tested on **Ubuntu 22.04 LTS** (Jammy) and **Ubuntu 24.04 LTS** (Noble).

---

## Quick start

```sh
# 1. Install everything automatically
sudo ./scripts/setup-host.sh

# 2. Verify the installation
./scripts/setup-host.sh --check

# 3. Build an OpenBSD VM (QEMU is recommended on Linux)
./build.sh -qu

# 4. Start the VM
./run.sh -qu
```

---

## What setup-host.sh installs

| Tool | Purpose |
|------|---------|
| `qemu-system-x86_64` | QEMU/KVM virtualisation (recommended on Linux) |
| `libvirt` + `virtinst` | Libvirt daemon for QEMU management |
| `packer` | Build VM images from a template |
| `vagrant` | Manage VM lifecycle |
| `vagrant-libvirt` plugin | QEMU/KVM Vagrant provider |
| `curl`, `git`, `rsync` | General utilities |
| `kvm-ok` check | Verify hardware acceleration |

---

## Manual installation

If you prefer to install tools manually or on a non-Ubuntu system:

### Packer

```sh
# Official HashiCorp release (amd64)
PACKER_VERSION="1.11.0"
curl -fsSL "https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip" \
  -o /tmp/packer.zip
sudo unzip -o /tmp/packer.zip -d /usr/local/bin/
rm /tmp/packer.zip
sudo chmod +x /usr/local/bin/packer
packer version
```

### Vagrant

```sh
VAGRANT_VERSION="2.4.1"
curl -fsSL "https://releases.hashicorp.com/vagrant/${VAGRANT_VERSION}/vagrant_${VAGRANT_VERSION}-1_amd64.deb" \
  -o /tmp/vagrant.deb
sudo dpkg -i /tmp/vagrant.deb
vagrant --version
```

### QEMU + KVM

```sh
sudo apt-get install -y qemu-system-x86 qemu-utils libvirt-daemon-system \
    libvirt-clients virtinst bridge-utils cpu-checker
sudo usermod -aG libvirt,kvm "$USER"
# Log out and back in, then verify:
kvm-ok
```

### vagrant-libvirt plugin

```sh
vagrant plugin install vagrant-libvirt
```

### VirtualBox (alternative to QEMU)

VirtualBox is not required when using QEMU, but can be installed if preferred:

```sh
# Follow the official VirtualBox instructions for your Ubuntu version:
# https://www.virtualbox.org/wiki/Linux_Downloads
sudo apt-get install -y virtualbox
```

---

## Verifying the installation

```sh
# Check that all tools are present
./scripts/setup-host.sh --check

# Inspect the Packer configuration
cd packer && packer inspect openbsd.pkr.hcl && cd ..

# Validate the Packer HCL (syntax only, no build)
cd packer && packer validate -syntax-only openbsd.pkr.hcl && cd ..
```

---

## KVM hardware acceleration

QEMU builds are very slow without hardware acceleration.  Verify it is enabled:

```sh
kvm-ok
# Expected output:
# INFO: /dev/kvm exists
# KVM acceleration can be used
```

If you see `KVM acceleration can NOT be used`:

* **Bare metal**: enable VT-x/AMD-V in BIOS/UEFI.
* **Inside a VM** (e.g. cloud instance or another VM): enable nested
  virtualisation on the outer hypervisor.
  - AWS: use a metal instance type or enable nested virt.
  - VirtualBox outer VM: `VBoxManage modifyvm <name> --nested-hw-virt on`
  - KVM outer VM: pass `-cpu host` or add `vmx`/`svm` to the CPU flags.

---

## Disk space requirements

| Item | Approximate size |
|------|-----------------|
| OpenBSD install ISO | 600 MB |
| Packer build output (qcow2 or OVF) | 2–4 GB |
| Vagrant box (compressed) | 1–2 GB |
| Running VM disk | 4–8 GB |

Ensure at least **20 GB** of free disk space before building.

---

## Troubleshooting

### `packer: command not found`
Packer is not on `$PATH`.  Install it or add `/usr/local/bin` to your PATH.

### `vagrant: command not found`
Vagrant is not installed.  Run `sudo ./scripts/setup-host.sh`.

### Permission denied on `/dev/kvm`
Add yourself to the `kvm` group and log out/in:
```sh
sudo usermod -aG kvm "$USER"
```

### `Error: VM already exists. Destroy it first`
A previous VM was not cleaned up:
```sh
./clean.sh
```

### Packer download is very slow
The build script uses `https://mirrors.openbsd.org` by default.  Edit
`packer/versions.conf` to change the `OPENBSD_MIRROR` variable to a
geographically closer mirror from https://www.openbsd.org/ftp.html.

---

## References

* Packer documentation: https://developer.hashicorp.com/packer/docs
* Vagrant documentation: https://developer.hashicorp.com/vagrant/docs
* vagrant-libvirt: https://vagrant-libvirt.github.io/vagrant-libvirt/
* KVM on Ubuntu: https://help.ubuntu.com/community/KVM/Installation
