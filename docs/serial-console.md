# Serial Console (TTY / Virtual RS-232)

This document explains how the virtual serial console works in openbsd-box,
why it is useful, and how to capture output from it.

---

## Why a serial console?

When a virtual machine panics, hangs, or is under heavy fuzzing load, the SSH
connection may become unavailable.  The serial console (com0 in OpenBSD
terminology) is a separate, low-level channel that:

* receives kernel panic messages and backtraces
* allows boot-loader interaction (e.g. `boot -s` for single-user mode)
* works even when the network stack or SSH daemon has crashed
* can be redirected to a plain file by the hypervisor for automatic capture

---

## OpenBSD serial console configuration

`packer/templates/setup.sh.pkrtpl` writes two files during the Packer build:

### `/etc/boot.conf`
```
stty com0 115200
set tty com0
```
This tells the OpenBSD boot loader to use `com0` at 115200 baud as the
primary console.

### `/etc/ttys` (patched)
The `tty00` entry is changed from `off` to `on` so that `getty` listens on
the serial port and allows login (useful for debugging without SSH).

---

## Hypervisor serial port configuration

### QEMU
The QEMU builder in `packer/openbsd.pkr.hcl` passes:
```hcl
qemuargs = [["-serial", "file:${var.vm_serial_log}"]]
```
`vm_serial_log` defaults to `/tmp/openbsd-serial.log` and is overridden by
`build.sh` to `builds/<BUILD_ID>/serial.log`.

At runtime (`vagrant up --provider=libvirt`), the Vagrantfile configures:
```ruby
libv.serial :type => "file", :source => {:path => SERIAL_LOG}
```

### VirtualBox
The VirtualBox builder in `packer/openbsd.pkr.hcl` passes:
```hcl
vboxmanage = [
  ...
  ["modifyvm", "{{ .Name }}", "--uart1",     "0x3F8", "4"],
  ["modifyvm", "{{ .Name }}", "--uartmode1", "file",  "${var.vm_serial_log}"]
]
```
COM1 (`0x3F8`, IRQ 4) maps to `tty00`/`com0` in OpenBSD.

At runtime, the Vagrantfile configures:
```ruby
vbox.customize ["modifyvm", :id, "--uart1",     "0x3F8", "4"]
vbox.customize ["modifyvm", :id, "--uartmode1", "file", SERIAL_LOG]
```
The `SERIAL_LOG` variable defaults to `/tmp/openbsd-serial.log` and can be
overridden via the environment variable `VAGRANT_SERIAL_LOG`.

---

## Capturing console output

### During Packer builds
The serial log is written to `builds/<BUILD_ID>/serial.log` automatically.
Inspect it after the build:
```sh
cat builds/v7.8_b001_20250101_120000/serial.log
```

### During Vagrant runtime
`run.sh` sets `VAGRANT_SERIAL_LOG` to `builds/<BUILD_ID>/serial-runtime.log`.
You can also watch it in real time using the provided helper:
```sh
./scripts/console-capture.sh builds/v7.8_b001_20250101_120000/serial-runtime.log
```
Or with a custom path:
```sh
SERIAL_LOG=/tmp/openbsd-serial.log ./scripts/console-capture.sh
```

### Manual tail
If you prefer a simple approach:
```sh
tail -F /tmp/openbsd-serial.log
```

---

## Example: capturing a kernel panic

1. Start the VM and the console capture in separate terminals:
   ```sh
   # Terminal 1
   ./run.sh -qu

   # Terminal 2
   ./scripts/console-capture.sh
   ```

2. Trigger the panic in the VM (e.g. via a fuzzer or `ddb` command):
   ```sh
   vagrant ssh
   doas -n sysctl kern.panic=1   # force immediate panic
   ```

3. The crash output appears in Terminal 2 immediately:
   ```
   [2025-01-01T12:00:01] panic: kernel diagnostic assertion "..." failed
   [2025-01-01T12:00:01] Stopped at      db_enter+0x14: ...
   [2025-01-01T12:00:01] ddb{0}>
   ```
   The `ddb>` prompt means the kernel debugger is active.  The entire trace
   is captured in the serial log even after the VM becomes unresponsive.

---

## Accessing the boot loader

If the VM fails to boot, you can interact with the OpenBSD boot loader via the
serial console.  For VirtualBox, connect a terminal emulator to the named pipe
or file.  For QEMU, redirect the serial port to stdio:

```sh
# Build-time: override the serial output to stdio instead of a file
PKR_VAR_vm_serial_log="stdio" packer build ...  # (not recommended for automation)

# Runtime: use socat or screen with a Unix socket (libvirt approach)
virsh console <vm-name>
```

For interactive serial console access during Vagrant runs, consider changing
the Vagrantfile serial mode from `file` to `server` (VirtualBox) or
`pty`/`unix` (libvirt) and connecting with `screen` or `minicom`.

---

## References

* OpenBSD `boot(8)` man page: https://man.openbsd.org/boot.8
* OpenBSD `ttys(5)` man page: https://man.openbsd.org/ttys.5
* QEMU `-serial` option: https://www.qemu.org/docs/master/system/invocation.html
* VirtualBox serial ports: https://www.virtualbox.org/manual/ch03.html#serialports
