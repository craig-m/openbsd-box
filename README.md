# OpenBSD-box

![alt text](packer-http/puf150X129.gif "Puffy")

An [OpenBSD](https://www.openbsd.org/) learning / play / dev box. Built by [Packer](https://www.packer.io/), and run by [Vagrant](https://www.vagrantup.com/).

## packer build of VM image

Check the packer json:

```shell
packer validate openbsd.json
packer inspect openbsd.json
```

Convert to [HCL](https://github.com/hashicorp/hcl) with the command:

```shell
packer hcl2_upgrade -with-annotations openbsd.json
```

### Debugging packer builds

Logging is set by changing this environment variable.

Windows (powershell):

```shell
$env:PACKER_LOG=1
```

Mac/Linux/BSD:

```shell
export PACKER_LOG=1
```

You can use the env var `PACKER_LOG_PATH=/tmp/packer.log` to set a log file.

#### HyperV

Windows 10 build:

```shell
packer build -only=openbsd-hv -force openbsd.json
```

#### VirtualBox

Mac / Win / Linux build:

```shell
packer build -only=openbsd-vb -force openbsd.json
```

#### QEMU

Mac / Win / Linux build:

```shell
packer build -only=openbsd-qu -force openbsd.json
```

You will need a [VNC](https://en.wikipedia.org/wiki/Virtual_Network_Computing) client to monitor progress.

#### VMWare

Mac / Win / Linux build:

```shell
packer build -only=openbsd-vw -force openbsd.json
```

Vmware needs testing still.

## run OpenBSD VM with Vagrant

Imports our Box and create a VM from it:

```shell
vagrant validate Vagrantfile
vagrant up
```

### Hyper-V notes

You can enable nesting on HyperV. On an existing shutdown Vagrant vm:

```shell
Set-VMProcessor -VMName openbsd -ExposeVirtualizationExtensions $true
```

You need to do this to use [vmm](https://www.openbsd.org/faq/faq16.html), the OpenBSD hypervisor.

### Libvirt notes

Libvirt is not one of the standard providers, you need to install the plugin first.

```shell
vagrant plugin install vagrant-libvirt
vagrant up --provider=libvirt
```

### use

Login:

```shell
vagrant ssh
```

Learn OpenBSD.

```shell
man afterboot
man intro
man security
```

### clean up

Remove everything:

```shell
vagrant destroy
vagrant box remove openbsd
```

## scripts

The steps above have been automated in build.sh/ps1, and clean.sh/ps1.

## links

Useful documentation + code + guides

**OpenBSD Docs**
* https://www.openbsd.org/faq/

**guides**
* https://openbsdjumpstart.org/
* https://why-openbsd.rocks/fact/

**packer projects**
* https://github.com/upperstream/packer-templates/tree/master/openbsd
* https://github.com/lavabit/robox

**packer plugins**
* https://github.com/double-p/vagrant-openbsd