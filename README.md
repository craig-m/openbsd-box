# OpenBSD-box

![alt text](packer-http/puf150X129.gif "Puffy")

An [OpenBSD](https://www.openbsd.org/) learning / play / dev [VM](https://en.wikipedia.org/wiki/Virtual_machine) to be built and run from your own desktop.

Created by [Packer](https://www.packer.io/) and run by [Vagrant](https://www.vagrantup.com/).

## build OpenBSD VM

Packer will download the OpenBSD installation media, [stable](https://www.openbsd.org/stable.html) `installXX.iso`, for us and then handle the full installation start to finish automatically with the end result being a reusable VM image.

Check the packer [HCL](https://github.com/hashicorp/hcl):

```shell
packer validate openbsd.pkr.hcl
packer inspect openbsd.pkr.hcl
```

### Debugging packer builds

Logging is set by changing this environment variable, if anything goes wrong verbosity can be increased.

Windows (powershell):

```shell
$env:PACKER_LOG=1
```

Mac/Linux/BSD:

```shell
export PACKER_LOG=1
```

You can use the env var `PACKER_LOG_PATH=/tmp/packer.log` to set a log file.

#### VirtualBox

[VirtualBox](https://www.virtualbox.org/) [build](https://www.packer.io/docs/builders/virtualbox)

```shell
packer build -only=openbsd-vb -force openbsd.pkr.hcl
```

#### HyperV

Hyper-V [build](https://www.packer.io/docs/builders/hyperv) on Windows desktops

```shell
packer build -only=openbsd-hv -force openbsd.pkr.hcl
```

##### Hyper-V notes

You can enable nesting on HyperV. On an existing shutdown Vagrant vm:

```shell
Set-VMProcessor -VMName openbsd -ExposeVirtualizationExtensions $true
```

You need to do this to use [vmm](https://www.openbsd.org/faq/faq16.html), the OpenBSD hypervisor.

#### QEMU

QEMU is a generic and open source machine emulator and virtualizer.

[QEMU](https://www.qemu.org/) [build](https://www.packer.io/docs/builders/qemu)

```shell
packer build -only=openbsd-qu -force openbsd.pkr.hcl
```

You will need a [VNC](https://en.wikipedia.org/wiki/Virtual_Network_Computing) client to monitor progress.

#### VMWare

VMware [build](https://www.packer.io/docs/builders/vmware)

```shell
packer build -only=openbsd-vw -force openbsd.pkr.hcl
```

Vmware needs testing still.

## run OpenBSD VM

Vagrant is a tool for managing portable virtual machines, it's a wrapper on virtualization.

This imports the Box we just made and will then create a VM from it:

```shell
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
vagrant box remove openbsd
```

## scripts

The steps above have been automated in build and clean Shell and PowerShell.

```shell
./build.ps1
vagrant ssh
tmux
exit
./clean.ps1
```

## links

Useful documentation + code + guides

```shell
man afterboot
man security
```

**OpenBSD Docs**
* https://www.openbsd.org/faq/

**guides**
* https://openbsdjumpstart.org/
* https://why-openbsd.rocks/fact/

**github**
* https://github.com/ligurio/awesome-openbsd
* https://github.com/sirredbeard/Awesome-UNIX

**packer projects**
* https://github.com/upperstream/packer-templates/tree/master/openbsd
* https://github.com/lavabit/robox

**packer plugins**
* https://github.com/double-p/vagrant-openbsd
