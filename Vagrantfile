#
# OpenBSD Vagrant box
#

# shared folder
MY_VM_CODE = "./vmcode/"
CODE_MNT = "/opt/vmcode"
CODE_MNT_OPT = ["dmode=775,fmode=644"]

Vagrant.configure("2") do |config|

    # VM options
    config.vm.box = "openbsd"
    config.vm.box_url = "file://boxes/OpenBSD.box"
    config.vm.box_check_update = false
    config.ssh.username = "puffy"
    config.ssh.insert_key = true
    config.ssh.forward_agent = false
    config.vm.synced_folder ".", "/vagrant", disabled: true

    # Virtual machines
    config.vm.define "openbsd" do |mainvm|
        config.vm.hostname = "openbsd"

        config.vm.synced_folder MY_VM_CODE, CODE_MNT, type: "rsync",
            mount_options: CODE_MNT_OPT,
            rsync__rsync_path: "doas rsync"
    end

    config.vm.provision :shell,
        :privileged => true, 
        :path => "scripts/vagrant.sh",
        :binary => true, 
        name: "vagrant sh"

end

# -*- mode: ruby -*-
# vi: ft=ruby :