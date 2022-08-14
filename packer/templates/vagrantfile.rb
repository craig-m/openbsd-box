#
# OpenBSD Vagrantfile template
#

Vagrant.require_version ">= 2.2.18"

# vagrant options
VAGRANT_DISABLE_VBOXSYMLINKCREATE = 1


# inline script used by action trigger
$inlinescript_post = <<-SCRIPT
echo '-------------------------------------------------------------------';
uname -a;
uptime;
echo '-------------------------------------------------------------------';
SCRIPT


Vagrant.configure("2") do |config|

    #
    # Box and VM config
    #

    config.vm.box = "{{ .BoxName }}"

    config.vm.hostname = "openbsd"
    config.vm.box_check_update = false
    config.vm.boot_timeout = 300
    config.ssh.guest_port = 22
    config.ssh.keep_alive = true
    config.ssh.forward_agent = false
    config.ssh.compression = false
    # ksh - public domain Korn shell!
    config.ssh.shell = "/bin/ksh"
    config.ssh.sudo_command = "doas -n %c"


    #
    # VM provider specific configs
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
        # custom options
        vbox.customize ["modifyvm", :id, "--audioout", "off"]
        vbox.customize ["modifyvm", :id, "--vram", 32]
    end

    # --- Libvirt ---
    config.vm.provider :libvirt do |libv, override|
        libv.disk_bus = "virtio"
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

    # --- parallels  ---
    config.vm.provider :parallels do |prl, override|
        prl.check_guest_tools = false
        prl.functional_psf    = false
    end


    #
    # port forwards
    #

    config.vm.network :forwarded_port, guest: 8888, host: 8080, auto_correct: true, id: 'webalt'

    #
    # action Triggers
    #

    config.trigger.after [:up, :provision, :resume, :reload] do |t|
        t.run_remote = {inline: $inlinescript_post, :privileged => false}
    end

    # prevent TLS error "ocsp response not current" from incorrect time
    config.trigger.after [:resume] do |t|
        t.run_remote = {inline: "rdate pool.ntp.org", :privileged => true}
    end


    #
    # Finished
    #

    config.vm.post_up_message = "----- OpenBSD box up -----"

end

# -*- mode: ruby -*-
# vi: set ft=ruby :