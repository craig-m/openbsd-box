# OpenBSD-box

An OpenBSD 6.8 learning/play setup, powered by Packer and Vagrant.

## build

To first create the Vagrant box image.

```shell
packer validate openbsd.json
packer inspect openbsd.json
```

### HyperV

Set debug (powershell only):

```shell
$env:PACKER_LOG=1
```

Windows 10 build:

```shell
packer build -only=openbsd-hv -force openbsd.json
```

(working + tested)

### VirtualBox

Debug (Mac/Linux only):

```shell
export PACKER_LOG=1
```

MacOS, Windows, Linux:

```shell
packer build -only=openbsd-vb -force openbsd.json
```

(work in progress)

### QEMU

MacOS, Windows, Linux:

```shell
packer build -only=openbsd-qu -force openbsd.json
```

(builds OK)

### VMWare

MacOS, Windows, Linux:

```shell
packer build -only=openbsd-vw -force openbsd.json
```

(not tested)

## run

Start the VM:

```shell
vagrant validate Vagrantfile
vagrant up
```

## use

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
