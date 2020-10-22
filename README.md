# OpenBSD-box

An OpenBSD learning/play setup, powered by Packer and Vagrant.

## build

To first create the Vagrant box image.

**HyperV**

```
packer build -only=openbsd-hv openbsd.json
```

**VirtualBox**

```
packer build -only=openbsd-vb openbsd.json
```

**QEMU**

```
packer build -only=openbsd-qu openbsd.json
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
man firstboot
```

## links

Useful documentation + code + guides

**packer projects**
* https://github.com/upperstream/packer-templates/tree/master/openbsd
* https://github.com/lavabit/robox

**packer plugins**
* https://github.com/double-p/vagrant-openbsd