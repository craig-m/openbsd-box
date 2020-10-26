# OpenBSD-box

An OpenBSD 6.8 learning/play setup, powered by Packer and Vagrant.

## build

To first create the Vagrant box image.

```shell
packer validate openbsd.json
packer inspect openbsd.json
```

### packer debug

Set debug on Windows (powershell):

```shell
$env:PACKER_LOG=1
```

Debug on Mac/Linux/BSD:

```shell
export PACKER_LOG=1
```

#### HyperV

Windows 10 build:

```shell
packer build -only=openbsd-hv -force openbsd.json
```

(working + tested)

#### VirtualBox

MacOS, Windows, Linux:

```shell
packer build -only=openbsd-vb -force openbsd.json
```

(work in progress)

#### QEMU

MacOS, Windows, Linux:

```shell
packer build -only=openbsd-qu -force openbsd.json
```

(builds OK)

#### VMWare

MacOS, Windows, Linux:

```shell
packer build -only=openbsd-vw -force openbsd.json
```

(not tested)

## run

This imports our Box and creates a VM from it:

```shell
vagrant validate Vagrantfile
vagrant up
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

**packer projects**
* https://github.com/upperstream/packer-templates/tree/master/openbsd
* https://github.com/lavabit/robox

**packer plugins**
* https://github.com/double-p/vagrant-openbsd
