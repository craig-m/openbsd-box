#
# OpenBSD Vagrant box
#

# vm vars
MY_VM_RAM = "1048"
MY_VM_CPU = "2"
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
    config.ssh.sudo_command = "doas -n %c"
    config.vm.synced_folder ".", "/vagrant", disabled: true

    #
    # Virtual machines
    #

    config.vm.define "openbsd" do |mainvm|
        config.vm.hostname = "openbsd"

        config.vm.synced_folder MY_VM_CODE, CODE_MNT, type: "rsync", 
            mount_options: CODE_MNT_OPT,
            rsync__exclude: ".git/ .vagrant/",
            rsync__rsync_path: "doas rsync",
            rsync__args: "--archive --delete --verbose"

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