# OpenBSD-Box

![alt text](docs/puf150X129.gif "Puffy")

An [OpenBSD](https://www.openbsd.org/) learning/dev [VM](https://en.wikipedia.org/wiki/Virtual_machine) to be built and run from your own desktop.

Created by [Packer](https://www.packer.io/) and run by [Vagrant](https://www.vagrantup.com/).

## Quick start (Linux / Ubuntu LTS host)

```sh
# 1. Install host dependencies (once)
sudo ./scripts/setup-host.sh

# 2. Build an OpenBSD VM image (QEMU recommended on Linux)
./build.sh -qu

# 3. Start the VM
./run.sh -qu

# 4. Connect
cd vagrant && vagrant ssh
```

See [docs/host-setup.md](docs/host-setup.md) for a full walkthrough.

## Build OpenBSD VM

Packer downloads the OpenBSD installation media, [stable](https://www.openbsd.org/stable.html) `installXX.iso`, and then handles the full install automatically – with the result being a reusable Vagrant box stored in `builds/<build-id>/`.

### Selecting an OpenBSD version

```sh
# Default (latest, currently 7.8)
./build.sh -qu

# A specific version from the last 5 years
./build.sh -qu -V 7.6
./build.sh -vb -V 7.4

# Supported versions: 7.0 7.1 7.2 7.3 7.4 7.5 7.6 7.7 7.8
```

Before using a version other than the default, add its SHA256 checksum to
`packer/versions.conf` (see [docs/regression-testing.md](docs/regression-testing.md)).

### Check the Packer config

```shell
cd packer
packer validate openbsd.pkr.hcl
packer inspect openbsd.pkr.hcl
```

## Run OpenBSD VM

Vagrant is a tool for managing portable virtual machines – a wrapper around virtualisation.

This imports the box from `builds/` and creates a VM from it. The latest build is used by default, or you can specify a build ID:

```shell
vagrant box add builds/<build-id>/OpenBSD.box --name OpenBSD.box
cd ../vagrant
vagrant validate Vagrantfile
vagrant up
```

### Use

Login:

```shell
vagrant ssh
man intro
```

You might want to use `vagrant rsync-auto` in a separate shell.

### Clean up

Remove everything when finished:

```shell
exit
vagrant destroy
vagrant box remove OpenBSD.box
```

## Scripts

The steps above are wrapped in `build.{sh,ps1}` (build only), `run.{sh,ps1}` (start VM), and `clean.{sh,ps1}` (tear down).

Each run of the build script creates a timestamped folder under `builds/` (e.g. `builds/v7.8_b001_20250101_120000/`), so multiple builds can coexist and you can choose which one to run.

```shell
# Step 1 – build the box
./build.sh -qu -V 7.8

# Step 2 – start the VM (uses latest build by default)
./run.sh -qu

# Or specify a particular build
./run.sh -qu v7.8_b001_20250101_120000

vagrant ssh
tmux
exit

# Tear down
./clean.sh
```

For better or worse, you can install [Powershell](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell) on macOS and Linux.

Win 10 includes Windows [Subsystem for Linux](https://docs.microsoft.com/en-us/windows/wsl/) which Vagrant also [supports](https://www.vagrantup.com/docs/other/wsl).

## Serial console (TTY / crash capture)

A virtual RS-232 serial port (`com0`) is enabled in every VM built by this
project.  The hypervisor captures its output to a file on the host:

```
builds/<build-id>/serial.log          ← output during the Packer build
builds/<build-id>/serial-runtime.log  ← output while the VM runs
```

Watch the console in real time (useful during fuzzing or stress tests):

```shell
./scripts/console-capture.sh
```

If the kernel panics, the panic message is captured in the serial log even
when SSH is unavailable.  See [docs/serial-console.md](docs/serial-console.md).

## Fuzzing

See [docs/fuzzing.md](docs/fuzzing.md) for a guide on:

* User-space fuzzing with **afl++**
* Kernel fuzzing with **syzkaller**
* Network protocol fuzzing
* Crash triage using the serial console

## Regression testing

Build and test against any OpenBSD release from the last five years:

```shell
./build.sh -qu -V 7.6   # build OpenBSD 7.6
./run.sh   -qu           # start it
./build.sh -qu -V 7.4   # build OpenBSD 7.4
./run.sh   -qu           # start it
```

See [docs/regression-testing.md](docs/regression-testing.md) for a scripted
multi-version test matrix.

## Docs

* [docs/architecture.md](docs/architecture.md) – components, data-flow, and hypervisor matrix
* [docs/host-setup.md](docs/host-setup.md) – Ubuntu LTS host setup
* [docs/serial-console.md](docs/serial-console.md) – serial TTY and crash capture
* [docs/fuzzing.md](docs/fuzzing.md) – fuzzing instrumentation guide
* [docs/regression-testing.md](docs/regression-testing.md) – multi-version regression testing
* [docs/links.md](docs/links.md) – external references

```shell
man afterboot
man security
```

**OpenBSD Docs**
* https://www.openbsd.org/faq/
* https://man.openbsd.org/
