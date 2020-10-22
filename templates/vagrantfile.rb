# This Vagrantfile is packaged with the box.

Vagrant.require_version ">= 2.2.9"

# openbsd VM options
MY_VM_RAM = "4096"
MY_VM_CPU = "4"
MY_VM_CODE = "./vmcode/"

# vagrant options
VAGRANT_API_VER = "2"
VAGRANT_DISABLE_VBOXSYMLINKCREATE = 1
CODE_MNT = "/opt/code"
CODE_MNT_OPT = ["dmode=775,fmode=644"]

# inline script used by action trigger
$inlinescript_post = <<-SCRIPT
echo '-------------------------------------------------------------------';
echo 'Hello, welcome to'
uname -a;
echo '-------------------------------------------------------------------';
SCRIPT


Vagrant.configure("2") do |config|


    #
    # Box and VM config
    #

    config.vm.box = "{{ .BoxName }}"

    config.vm.hostname = "centos8vm"
    config.vm.box_check_update = false
    config.vm.boot_timeout = 300
    config.ssh.username = "root"
    config.ssh.guest_port = 22
    config.ssh.insert_key = true
    config.ssh.keep_alive = true
    config.ssh.forward_agent = false
    config.ssh.compression = false

    def is_windows
        RbConfig::CONFIG['host_os'] =~ /mswin|mingw|cygwin/
    end


    #
    # VM provider specific configs
    # https://www.vagrantup.com/docs/multi-machine/
    #

    # --- Hyper-V ---
    config.vm.provider :hyperv do |hpv, override|
        hpv.vmname = "openbsd"
        # allows for nested VMs
        hpv.enable_virtualization_extensions = true
    end

    # --- VirtualBox ---
    config.vm.provider :virtualbox do |vbox, override|
        vbox.name = "openbsd"
        vbox.gui = false
        vbox.check_guest_additions = false
    end

    # --- Libvirt ---
    config.vm.provider :libvirt do |libv, override|
        libv.disk_bus = "virtio"
        #config.vagrant.plugins = ["vagrant-libvirt"]
    end

    # --- VMWare ---
    ["vmware_fusion", "vmware_workstation", "vmware_desktop"].each do |provider|
        config.vm.provider provider do |vmw, override|
            vmw.ssh_info_public = true
            vmw.whitelist_verified = true
            vmw.gui = false
            vmw.vmx["cpuid.coresPerSocket"] = "1"
            vmw.vmx["memsize"] = "2048"
            vmw.vmx["numvcpus"] = "2"
        end
    end


    #
    # SSH Port Forwards
    #

    #config.vm.define "centos8vm" do |mainvm|
    #    config.vm.network :forwarded_port,
    #        guest: 8989, host: 8989,
    #        auto_correct: true,
    #        id: 'webalt'
    #end


    #
    # action Triggers
    # https://www.vagrantup.com/docs/triggers/
    #

    config.trigger.after [:up, :provision, :resume, :reload] do |t|
        t.run_remote = {inline: $inlinescript_post, 
            :privileged => false}
    end


    #
    # Finished
    #
    config.vm.post_up_message = "----- OpenBSD up -----"
end

# -*- mode: ruby -*-
# vi: set ft=ruby :