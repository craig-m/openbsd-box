# OpenBSD-Box

![alt text](docs/puf150X129.gif "Puffy")

An [OpenBSD](https://www.openbsd.org/) learning/dev [VM](https://en.wikipedia.org/wiki/Virtual_machine) to be built and run from your own desktop.

Created by [Packer](https://www.packer.io/) and run by [Vagrant](https://www.vagrantup.com/).

## build OpenBSD VM

Packer will download the OpenBSD installation media, [stable](https://www.openbsd.org/stable.html) `installXX.iso`, and then handle the full install start to finish - all automatically - with the end result being a reusable image stored in `builds/<build-id>/`.

Check the packer [HCL](https://github.com/hashicorp/hcl):

```shell
cd packer
packer validate openbsd.pkr.hcl
packer inspect openbsd.pkr.hcl
```

## run OpenBSD VM

Vagrant is a tool for managing portable virtual machines, it's a wrapper on virtualization.

This imports the Box from the `builds/` folder and creates a VM from it. By default the latest build is used, or you can specify a build ID:

```shell
vagrant box add builds/<build-id>/OpenBSD.box --name OpenBSD.box
cd ../vagrant
vagrant validate Vagrantfile
vagrant up
```

### use

Login:

```shell
vagrant ssh
man intro
```

You might want to use `vagrant rsync-auto` in a separate shell.

### clean up

Remove everything when finished:

```shell
exit
vagrant destroy
vagrant box remove OpenBSD.box
```

## scripts

The steps above have been split into `build.{sh,ps1}` (build only) and `run.{sh,ps1}` (start VM), with `clean.{sh,ps1}` to tear everything down.

Each run of the build script creates a timestamped folder under `builds/` (e.g. `builds/v7.1_b001_20240101_120000/`), so multiple builds can coexist and you can choose which one to run.

```shell
# Step 1 – build the box (outputs to builds/<build-id>/)
./build.sh -vb

# Step 2 – start the VM (uses latest build by default)
./run.sh -vb

# Or specify a particular build
./run.sh -vb v7.1_b001_20240101_120000

vagrant ssh
tmux
exit

# Tear down
./clean.sh
```

For better or worse, you can install [Powershell](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell) on MacOS and Linux.

Win 10 includes Windows [Subsystem for Linux](https://docs.microsoft.com/en-us/windows/wsl/) which Vagrant also [supports WSL](https://www.vagrantup.com/docs/other/wsl).

## Doco

Useful documentation + code + guides

```shell
man afterboot
man security
```

**OpenBSD Docs**
* https://www.openbsd.org/faq/
* https://man.openbsd.org/
