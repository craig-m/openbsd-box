# OpenBSD-box

An [OpenBSD](https://www.openbsd.org/) (6.8) learning / play / toy setup. 

Built by:

* [Packer](https://www.packer.io/) 1.6.5
* [Vagrant](https://www.vagrantup.com/) 2.2.10

## packer build

To first create the Vagrant box image first check the packer json.

```shell
packer validate openbsd.json
packer inspect openbsd.json
```

### Debugging packer builds

Logging is set via an environment variable.

Set debug on Windows (powershell):

```shell
$env:PACKER_LOG=1
```

Set debug on Mac/Linux/BSD:

```shell
export PACKER_LOG=1
```

You can use `PACKER_LOG_PATH=/tmp/packer.log` to set a file location.

#### HyperV

Windows 10 build:

```shell
packer build -only=openbsd-hv -force openbsd.json
```

Enable nesting on HyperV VM (on existing shutdown vm/box):

```
Set-VMProcessor -VMName openbsd -ExposeVirtualizationExtensions $true
```

* Tested on release 2004

#### VirtualBox

MacOS/Windows/Linux build:

```shell
packer build -only=openbsd-vb -force openbsd.json
```

* Tested on Virtualbox 6.1.16 + MacOS
* Tested on Virtualbox 6.1 + Ubuntu 20.04
* Tested on Virtualbox 6.1 + Windows 10

#### QEMU

MacOS/Windows/Linux build:

```shell
packer build -only=openbsd-qu -force openbsd.json
```

* Tested on QEMU 5.0.0 + Ubuntu 20.10
* Tested on QEMU 5.1.0 + Fedora 33

#### VMWare

MacOS/Windows/Linux build:

```shell
packer build -only=openbsd-vw -force openbsd.json
```

(work in progress)

## run

This imports our Box and creates a VM from it:

```shell
vagrant validate Vagrantfile
vagrant up
```

### run on Libvirt

This is not one of the standard providers, you need to install the plugin first.

```shell
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

## links

Useful documentation + code + guides

**OpenBSD Docs**
* https://www.openbsd.org/faq/

**guides**
* https://openbsdjumpstart.org/

**packer projects**
* https://github.com/upperstream/packer-templates/tree/master/openbsd
* https://github.com/lavabit/robox

**packer plugins**
* https://github.com/double-p/vagrant-openbsd
