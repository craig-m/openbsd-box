# OpenBSD-box

An [OpenBSD](https://www.openbsd.org/) learning / play / dev box.

The default desktop [FVWM](https://www.fvwm.org/) is used.

Built by:

* [Packer](https://www.packer.io/)
* [Vagrant](https://www.vagrantup.com/)

## packer build

Check the packer json:

```shell
packer validate openbsd.json
packer inspect openbsd.json
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

Enable nesting on HyperV VM (on an existing shutdown vm/box):

```shell
Set-VMProcessor -VMName openbsd -ExposeVirtualizationExtensions $true
```

* Tested on release 2004

#### VirtualBox

MacOS/Windows/Linux build:

```shell
packer build -only=openbsd-vb -force openbsd.json
```

* Tested on Virtualbox 6.1 + MacOS / Ubuntu 20.04 / Windows 10

#### QEMU

MacOS/Windows/Linux build:

```shell
packer build -only=openbsd-qu -force openbsd.json
```

* Tested on QEMU 5.0 + Ubuntu 20.10
* Tested on QEMU 5.1 + Fedora 33

#### VMWare

MacOS/Windows/Linux build:

```shell
packer build -only=openbsd-vw -force openbsd.json
```

(work in progress)

## run

Imports our Box and create a VM from it:

```shell
vagrant validate Vagrantfile
vagrant up
```

### run on Libvirt

Libvirt is not one of the standard providers, you need to install the plugin first.

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

### clean up

Remove everything:

```shell
vagrant destroy
vagrant box remove openbsd
```

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
