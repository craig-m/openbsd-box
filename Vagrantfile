#
# OpenBSD Vagrant box
#

# vm vars
MY_VM_RAM = "2048"
MY_VM_CPU = "4"
MY_VM_CODE = "./vmcode/"
CODE_MNT = "/opt/vmcode"
CODE_MNT_OPT = ["dmode=775,fmode=644"]

# vagrant options
VAGRANT_API_VER = "2"
VAGRANT_DISABLE_VBOXSYMLINKCREATE = 1


Vagrant.configure("2") do |config|

    #
    # VM config
    #

    config.vm.box = "openbsd"
    config.vm.box_url = "file://boxes/OpenBSD.box"
    config.vm.box_check_update = false
    config.ssh.username = "puffy"
    config.ssh.password = "puffypass"
    config.ssh.insert_key = true
    config.ssh.keep_alive = true
    config.ssh.shell = "/bin/ksh"
    config.ssh.forward_agent = false
    config.vm.synced_folder ".", "/vagrant", disabled: true

    #
    # Virtual machines
    #

    config.vm.define "openbsd" do |mainvm|
        config.vm.hostname = "openbsd"
        #
        # provider specific conf
        #
        # ------ Windows Hyper-V ------
        config.vm.provider :hyperv do |hpv, override|
            hpv.memory = MY_VM_RAM
            hpv.maxmemory = MY_VM_RAM
            hpv.cpus = MY_VM_CPU
            override.vm.synced_folder MY_VM_CODE, CODE_MNT, type: "rsync", mount_options: CODE_MNT_OPT
        end
        #
        # ------ Libvirt ------
        config.vm.provider :libvirt do |libv, override|
            override.vm.synced_folder MY_VM_CODE, CODE_MNT, type: "rsync", mount_options: CODE_MNT_OPT
        end
        #
        # ------ KVM host ------
        config.vm.provider :kvm do |kvm, override|
        end
        #
        # ------ VirtualBox ------
        config.vm.provider :virtualbox do |vbox, override|
            override.vm.synced_folder MY_VM_CODE, CODE_MNT, type: "rsync", mount_options: CODE_MNT_OPT
        end
        #
    end


    #
    # provision tasks
    #

    config.vm.provision :shell,
        inline: "echo 'Hello, vm.provision tasks running.'"

    config.vm.provision :shell,
        :privileged => true, 
        :path => "scripts/vagrant.sh",
        :binary => true, 
        name: "vagrant sh"

end

# -*- mode: ruby -*-
# vi: ft=ruby :
