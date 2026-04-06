# Fuzzing with openbsd-box

This document describes how to instrument fuzzing runs inside an OpenBSD VM
and how to capture crash information via the serial console.

---

## Why fuzz inside a VM?

Running a fuzzer inside a VM gives you:

* **Isolation** – crashes cannot affect the host.
* **Reproducibility** – snapshot the disk before fuzzing, restore after each run.
* **Console capture** – kernel panics appear on the serial port even when SSH is gone.
* **Clean state** – destroy and recreate the VM between campaigns.

---

## Serial console crash capture

The serial console is the most important piece of crash-capture infrastructure.
When the OpenBSD kernel panics, the panic message is printed to `com0` before
the machine halts.  The hypervisor captures `com0` output to a file on the host.

See [serial-console.md](serial-console.md) for full details.  Quick summary:

```sh
# In one terminal – watch the console
./scripts/console-capture.sh

# In another terminal – run the VM and your fuzzer
./run.sh -qu
vagrant ssh
```

---

## User-space fuzzing with afl++

[afl++](https://github.com/AFLplusplus/AFLplusplus) (American Fuzzy Lop plus
plus) is a popular coverage-guided fuzzer.  You can install and use it inside
the OpenBSD VM.

### Install inside the VM

```sh
# OpenBSD ports have afl++ (check current port name)
doas pkg_add afl++
# or build from source via pkgsrc
```

### Instrument your target

```sh
# Compile with afl instrumentation
CC=afl-clang-fast ./configure
make

# Or use afl-cc wrapper if clang is not available
CC=afl-cc make
```

### Run a fuzzing campaign

```sh
# Create input corpus
mkdir -p /tmp/in /tmp/out
echo "hello" > /tmp/in/seed

# Start fuzzing (single process)
afl-fuzz -i /tmp/in -o /tmp/out -- ./target @@

# Multi-core: start additional secondary instances
afl-fuzz -i /tmp/in -o /tmp/out -S fuzzer02 -- ./target @@
```

### Monitor progress

```sh
# In a separate terminal
afl-whatsup /tmp/out
```

---

## Kernel fuzzing (syzkaller)

[syzkaller](https://github.com/google/syzkaller) is a kernel syscall fuzzer
that has OpenBSD support.

### Architecture

```
Host (Linux)
  └─ syz-manager  ←→  SSH  ←→  VM (OpenBSD)
                               └─ syz-executor (inside VM)
```

syzkaller uses SSH to deploy `syz-executor` into the VM, runs it, and monitors
for crashes via SSH or a serial port.

### Prerequisites

```sh
# On host
go install github.com/google/syzkaller/...@latest
```

### Serial console integration

syzkaller can monitor the serial port for crash messages.  Point it at the log
file produced by the hypervisor:

```json
{
    "target": "openbsd/amd64",
    "http": "127.0.0.1:56741",
    "workdir": "/tmp/syz-work",
    "kernel_obj": "/path/to/openbsd-src/sys/arch/amd64/compile/GENERIC.MP",
    "image": "builds/v7.8_b001_.../OpenBSD.box",
    "ssh_key": "~/.vagrant.d/insecure_private_key",
    "vm": {
        "count": 2,
        "cpu": 2,
        "mem": 2048,
        "qemu": "qemu-system-x86_64"
    }
}
```

The `console` field in the syzkaller config can point to a socat process that
reads the QEMU serial output socket.

---

## Network fuzzing

For network protocol fuzzing, the VM exposes:

* SSH on a host-forwarded port (Vagrant default: 2222)
* Port 8888 inside the VM forwarded to host:8080

You can run `boofuzz`, `radamsa`, or any other network fuzzer from the host
and direct it at the forwarded port.

```sh
# Example: fuzz the httpd daemon listening on port 80 inside the VM
# (forwarded to host port 8080 in the Vagrantfile)
pip install boofuzz
python3 my-http-fuzz.py --target 127.0.0.1 --port 8080
```

If httpd crashes, the kernel or service restart message will appear on the
serial console.

---

## Capturing and triaging crashes

### Automated crash detection

Run `console-capture.sh` and pipe its output to a grep filter:

```sh
./scripts/console-capture.sh | grep -E "(panic|fault|trap|killed)" | tee /tmp/crashes.log
```

### Crash artefact layout

After a crash, collect:

```
builds/<BUILD_ID>/
├── serial.log          ← console output during build
├── serial-runtime.log  ← console output during fuzzing run
└── packer.log          ← full build log
```

The `serial-runtime.log` will contain the panic string, register dump, and
stack trace.

### Reproducing a crash

1. Restore the VM to a clean snapshot (Vagrant boxes are immutable; just
   `vagrant destroy -f && ./run.sh ...` to get a fresh VM).
2. Replay the crashing input.
3. Watch the serial console for the panic.

---

## Recommended fuzzing workflow

```
1. Build a vanilla VM:     ./build.sh -qu -V 7.8
2. Start VM + console:     ./run.sh -qu &
                           ./scripts/console-capture.sh &
3. SSH into VM:            vagrant ssh
4. Install fuzzer:         doas pkg_add afl++
5. Run fuzzer:             afl-fuzz -i /tmp/in -o /tmp/out -- ./target @@
6. Monitor crashes:        (watch console-capture output on host)
7. On crash:               grep panic builds/.../serial-runtime.log
8. Clean up:               ./clean.sh
9. Repeat for next version: ./build.sh -qu -V 7.6
```

---

## References

* afl++: https://github.com/AFLplusplus/AFLplusplus
* syzkaller: https://github.com/google/syzkaller
* boofuzz: https://boofuzz.readthedocs.io/
* radamsa: https://gitlab.com/akihe/radamsa
* OpenBSD kernel debugging: https://man.openbsd.org/ddb.4
* OpenBSD DDB commands: https://man.openbsd.org/ddb.8
