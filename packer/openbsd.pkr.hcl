#
# OpenBSD packer HCL
#

packer {
  required_version = ">= 1.8.4"
  required_plugins {
    vagrant = {
      source  = "github.com/hashicorp/vagrant"
      version = "~> 1"
    }
    virtualbox = {
      version = ">= 1.1.1"
      source  = "github.com/hashicorp/virtualbox"
    }
    qemu = {
      version = ">= 1.1.3"
      source  = "github.com/hashicorp/qemu"
    }
  }
}


#
# variables
#

variable "iso_url" {
  type    = string
  default = "https://mirror.aarnet.edu.au/pub/OpenBSD/7.8/amd64/install78.iso"
}

variable "iso_checksum" {
  type    = string
  default = "a228d0a1ef558b4d9ec84c698f0d3ffd13cd38c64149487cba0f1ad873be07b2"
}

variable "headless" {
  type    = string
  default = "false"
}

variable "shutdown_cmd" {
  type    = string
  default = "doas -n shutdown -h -p now"
}

variable "ssh_port" {
  type    = string
  default = "22"
}

variable "ssh_timeout" {
  type    = string
  default = "7200s"
}

variable "ssh_user_name" {
  type    = string
  default = "bsduser"
}

variable "ssh_user_pass" {
  type    = string
  default = "puffypass"
  sensitive  = true
}

variable "ssh_root_pass" {
  type    = string
  default = "rootpass"
  sensitive  = true
}

variable "version" {
  type    = string
  default = ""
}

variable "output_dir" {
  type    = string
  default = "boxes"
}

variable "vm_boot_cmd" {
  type    = string
  default = "/install -a -f /install.conf && chroot /mnt < /setup.sh && reboot<wait><enter>"
}

variable "vm_boot_setupsh" {
  type    = string
  default = "ftp -o /setup.sh http://{{ .HTTPIP }}:{{ .HTTPPort }}/setup.sh<enter><wait>"
}

variable "vm_cpus" {
  type    = string
  default = "4"
}

variable "vm_disk" {
  type    = string
  default = "32768"
}

variable "vm_mem" {
  type    = string
  default = "2048"
}

variable "vm_serial_log" {
  type    = string
  default = "/tmp/openbsd-serial.log"
}

variable "vm_nic_mac" {
  type    = string
  default = "9c0a914daaff"
}


#
# source blocks
#

#
# -- QEMU --
#
source "qemu" "openbsd-qu" {
  boot_command        = [ "<wait5>S<enter><wait5>", "ifconfig vio0 inet autoconf<enter><wait10>",
                        "ftp -o /install.conf http://{{ .HTTPIP }}:{{ .HTTPPort }}/install.conf<enter><wait5>",
                        "${var.vm_boot_setupsh}", "${var.vm_boot_cmd}" ]
  boot_wait           = "40s"
  communicator        = "ssh"
  cpus                = "${var.vm_cpus}"
  disk_compression    = true
  disk_interface      = "virtio"
  disk_size           = "${var.vm_disk}"
  format              = "qcow2"
  headless            = "${var.headless}"
  http_content                     = {
    "/install.conf"                = templatefile( 
      "./templates/install-qemu.conf.pkrtpl", {
        my_pass = var.ssh_user_pass,
        my_user = var.ssh_user_name,
        root_pass = var.ssh_root_pass
      } )
    "/setup.sh"                    = templatefile( 
      "./templates/setup.sh.pkrtpl", {
        newuser = var.ssh_user_name,
        bversion = var.version
    } )
  }
  iso_checksum        = "${var.iso_checksum}"
  iso_url             = "${var.iso_url}"
  memory              = "${var.vm_mem}"
  net_device          = "virtio-net"
  qemu_binary         = "qemu-system-x86_64"
  shutdown_command    = "${var.shutdown_cmd}"
  ssh_password        = "${var.ssh_user_pass}"
  ssh_port            = "${var.ssh_port}"
  ssh_timeout         = "${var.ssh_timeout}"
  ssh_username        = "${var.ssh_user_name}"
  use_default_display = true
  vm_name             = "openbsd-qu"
  qemuargs            = [["-serial", "file:${var.vm_serial_log}"]]
}

#
# -- Virtual Box --
#
source "virtualbox-iso" "openbsd-vb" {
  boot_command         = [ "S<enter><wait>",
                        "ifconfig em0 inet autoconf<enter><wait5>",
                        "ftp -o /install.conf http://{{ .HTTPIP }}:{{ .HTTPPort }}/install.conf<enter><wait>",
                        "${var.vm_boot_setupsh}", "${var.vm_boot_cmd}" ]
  boot_wait            = "20s"
  communicator         = "ssh"
  cpus                 = "${var.vm_cpus}"
  disk_size            = "${var.vm_disk}"
  guest_additions_mode = "disable"
  guest_os_type        = "OpenBSD_64"
  headless             = "${var.headless}"
  http_content                     = {
    "/install.conf"                = templatefile( 
      "./templates/install.conf.pkrtpl", {
        my_pass = var.ssh_user_pass,
        my_user = var.ssh_user_name,
        root_pass = var.ssh_root_pass
      } )
    "/setup.sh"                    = templatefile( 
      "./templates/setup.sh.pkrtpl", {
        newuser = var.ssh_user_name,
        bversion = var.version
    } )
  }
  iso_checksum         = "${var.iso_checksum}"
  iso_url              = "${var.iso_url}"
  memory               = "${var.vm_mem}"
  shutdown_command     = "${var.shutdown_cmd}"
  ssh_password         = "${var.ssh_user_pass}"
  ssh_port             = "${var.ssh_port}"
  ssh_timeout          = "${var.ssh_timeout}"
  ssh_username         = "${var.ssh_user_name}"
  vboxmanage           = [["modifyvm", "{{ .Name }}", "--rtcuseutc", "on"],
                          ["modifyvm", "{{ .Name }}", "--ioapic", "off"],
                          ["modifyvm", "{{ .Name }}", "--natdnshostresolver1", "on"],
                          ["modifyvm", "{{ .Name }}", "--uart1", "0x3F8", "4"],
                          ["modifyvm", "{{ .Name }}", "--uartmode1", "file", "${var.vm_serial_log}"]]
  vm_name              = "openbsd-vb"
  vrdp_bind_address    = "127.0.0.1"
  vrdp_port_max        = 12000
  vrdp_port_min        = 11000
}

#
# build block
#

build {
  sources = ["source.qemu.openbsd-qu", "source.virtualbox-iso.openbsd-vb"]

  provisioner "shell" {
    expect_disconnect = false
    inline            = ["doas -n /opt/update.sh"]
    pause_before      = "60s"
    timeout           = "20m0s"
  }

  provisioner "shell" {
    expect_disconnect = true
    inline            = ["doas -n reboot"]
    pause_before      = "30s"
    timeout           = "6m0s"
  }

  provisioner "shell" {
    execute_command   = "doas ksh '{{ .Path }}'"
    expect_disconnect = false
    pause_before      = "30s"
    scripts           = ["packer.sh"]
  }

  provisioner "shell" {
    execute_command   = "ksh '{{ .Path }}'"
    expect_disconnect = false
    pause_before      = "30s"
    scripts           = ["test.sh"]
  }

  post-processor "artifice" {
    only  = ["virtualbox-iso.openbsd-vb"]
    files = ["output-openbsd-vb/openbsd-disk001.vmdk", "output-openbsd-vb/vbox-openbsd.ovf"]
  }

  post-processor "vagrant" {
    keep_input_artifact  = true
    compression_level    = 0
    include              = ["templates/info.json", "test.sh"]
    output               = "${var.output_dir}/OpenBSD.box"
    vagrantfile_template = "templates/vagrantfile.rb"
    vagrantfile_template_generated = false
  }

  post-processor "checksum" {
    checksum_types = ["sha512"]
    output         = "${var.output_dir}/{{ .BuildName }}.checksum"
  }

}
