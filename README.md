# OpenBSD-box

An OpenBSD learning/play setup, powered by Packer and Vagrant.

## build

To first create the Vagrant box image.

**HyperV**

Windows 10:

```shell
packer build -only=openbsd-hv -force openbsd.json
```

**VirtualBox**

MacOS, Windows, Linux:

```shell
packer build -only=openbsd-vb -force openbsd.json
```

**QEMU**

MacOS, Windows, Linux:

```shell
packer build -only=openbsd-qu -force openbsd.json
```

## run

start the system and login:

```
vagrant up
vagrant ssh
```

## use

Learn OpenBSD.

```
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