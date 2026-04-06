# Architecture

This document describes the overall structure, components, and data-flow of
**openbsd-box**: a Packer + Vagrant toolkit for building and running OpenBSD
virtual machines.

---

## Components

```
openbsd-box/
├── build.sh / build.ps1   ← Stage 1 – build a Vagrant box with Packer
├── run.sh   / run.ps1     ← Stage 2 – start a VM from a built box with Vagrant
├── clean.sh / clean.ps1   ← Tear down VMs and delete builds
├── scripts/
│   ├── setup-host.sh      ← One-time host dependency installer (Ubuntu LTS)
│   └── console-capture.sh ← Watch the serial console log in real-time
├── packer/
│   ├── openbsd.pkr.hcl    ← Packer build definition (HCL2)
│   ├── versions.conf      ← ISO URLs and SHA256 checksums per OpenBSD version
│   ├── packer.sh          ← In-VM optimisation (zero-fill, sync)
│   ├── test.sh            ← In-VM acceptance test run by Packer post-install
│   └── templates/
│       ├── install.conf.pkrtpl      ← Unattended install answers (VirtualBox)
│       ├── install-qemu.conf.pkrtpl ← Unattended install answers (QEMU)
│       ├── setup.sh.pkrtpl          ← First-boot provisioning script
│       ├── vagrantfile.rb           ← Embedded Vagrantfile baked into the box
│       └── info.json                ← Box metadata
└── vagrant/
    ├── Vagrantfile        ← Runtime VM configuration
    ├── vagrant.sh         ← Provisioner run by Vagrant on first boot
    └── vmcode/            ← Host folder rsync'd to /opt/vmcode inside the VM
        ├── enable-dwm.sh
        ├── install-pkgsrc.sh
        └── my-etc/        ← Example pf.conf and httpd.conf
```

---

## Stage 1 – Build (Packer)

```
Host
 │
 ├─ build.sh -qu [-V <version>]
 │     │
 │     ├─ sources versions.conf          (ISO URL + SHA256 for requested version)
 │     ├─ sets PKR_VAR_iso_url / PKR_VAR_iso_checksum / PKR_VAR_vm_serial_log
 │     └─ runs: packer build -only=qemu.openbsd-qu openbsd.pkr.hcl
 │
 └─ Packer
       │
       ├─ downloads install<XY>.iso (verified with SHA256)
       ├─ boots QEMU VM (-serial file:<BUILD_DIR>/serial.log)
       ├─ HTTP-serves install.conf + setup.sh to the installer
       ├─ OpenBSD auto-installs (/install -a -f /install.conf)
       ├─ setup.sh runs as root in the installed chroot:
       │     • creates /opt/
       │     • enables serial console (boot.conf + /etc/ttys)
       │     • configures X11 / XDM
       │     • installs packages (curl, rsync, dmidecode, dos2unix)
       │     • adds vagrant insecure SSH key
       │     • writes /opt/update.sh
       │     • touches /opt/.setup.sh (success marker)
       ├─ reboots into fresh system
       ├─ provisioner: runs /opt/update.sh (syspatch, pkg_add -u, fw_update)
       ├─ provisioner: reboots again
       ├─ provisioner: packer.sh (zero-fill disk for compression)
       ├─ provisioner: test.sh (validates services and packages)
       └─ post-processors:
             • vagrant  → builds/<BUILD_ID>/OpenBSD.box
             • checksum → builds/<BUILD_ID>/openbsd-<builder>.checksum
```

Build outputs are placed under `builds/<BUILD_ID>/`:

| File | Description |
|------|-------------|
| `OpenBSD.box` | Vagrant box archive |
| `serial.log` | Serial console output from the build |
| `packer.log` | Full Packer log |
| `openbsd-<builder>.checksum` | SHA-512 checksum of the box |

---

## Stage 2 – Run (Vagrant)

```
Host
 │
 ├─ run.sh -vb [<BUILD_ID>]
 │     │
 │     ├─ vagrant box add builds/<BUILD_ID>/OpenBSD.box
 │     ├─ sets VAGRANT_SERIAL_LOG=builds/<BUILD_ID>/serial-runtime.log
 │     └─ vagrant up --provider=virtualbox
 │
 └─ Vagrant
       │
       ├─ creates VM from box (serial port → VAGRANT_SERIAL_LOG on host)
       ├─ rsync: ./vmcode/ → /opt/vmcode/
       └─ runs vagrant.sh (disables sndiod)
```

Once up, the operator connects with `vagrant ssh`.

---

## Serial Console Data Flow

```
OpenBSD kernel / getty (com0 @ 115200)
        │  (virtual RS-232)
        ▼
QEMU   : -serial file:/path/serial.log
VirtualBox: --uartmode1 file /path/serial.log
        │
        ▼
  builds/<BUILD_ID>/serial[-runtime].log   ← host file
        │
        ▼
  scripts/console-capture.sh              ← tail -F + timestamps
```

During a kernel panic or crash, the panic string is emitted on com0 before the
machine stops, making it visible in `serial.log` even when SSH is unavailable.

---

## Hypervisor Support Matrix

| Provider | Build | Run | Serial console |
|----------|-------|-----|----------------|
| QEMU/KVM | ✅ `-qu` | ✅ libvirt | ✅ `-serial file:` |
| VirtualBox | ✅ `-vb` | ✅ virtualbox | ✅ `--uartmode1 file` |
| Hyper-V | ❌ | ✅ hyperv | ❌ (not configured) |
| VMware | ❌ | ✅ vmware_* | ❌ (not configured) |
| Parallels | ❌ | ✅ parallels | ❌ (not configured) |

QEMU/KVM is the recommended provider on Linux hosts.

---

## Network Layout (QEMU default)

```
Host (eth0)
 │
 ├─ NAT / user-mode network (QEMU default)
 │     ├─ VM eth0 (vio0): DHCP 10.0.2.x
 │     └─ port-forward: host:8080 → guest:8888
 └─ SSH: host port forwarded by Vagrant (usually 2222 → 22)
```

The firewall template (`vagrant/vmcode/my-etc/pf.conf`) allows inbound SSH
and HTTP, and blocks all other inbound traffic.
