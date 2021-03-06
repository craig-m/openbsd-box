#
# OpenBSD packer HCL
# generated from openbsd.json
#
packer {
  required_version = ">= 1.7.0"
}

#
# All generated input variables will be of 'string' type as this is how Packer JSON
# views them; you can change their type later on. Read the variables type
# constraints documentation
# https://www.packer.io/docs/templates/hcl_templates/variables#type-constraints for more info.
#
variable "headless" {
  type    = string
  default = "false"
}

variable "http_dir" {
  type    = string
  default = "packer-http/"
}

variable "iso_checksum" {
  type    = string
  default = "afd93d0afb6ee89db7dd34742ab126caeb11989f17dcf83dda901780e932ff9ef9a2d89d208b248f4966eb847999a4277213e0b623aded204230a3cd019b940b"
}

variable "iso_url" {
  type    = string
  default = "https://cdn.openbsd.org/pub/OpenBSD/6.9/amd64/install69.iso"
}

variable "shutdown_cmd" {
  type    = string
  default = "sudo shutdown -h -p now"
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
  default = "puffy"
}

variable "ssh_user_pass" {
  type    = string
  default = "puffypass"
}

variable "version" {
  type    = string
  default = ""
}

variable "vm_boot_cmd" {
  type    = string
  default = "/install -a -f /install.conf -m install && chroot /mnt < /setup.sh && reboot<wait><enter>"
}

variable "vm_boot_setupsh" {
  type    = string
  default = "ftp -o /setup.sh http://{{ .HTTPIP }}:{{ .HTTPPort }}/setup.sh<enter><wait>"
}

variable "vm_cpus" {
  type    = string
  default = "2"
}

variable "vm_disk" {
  type    = string
  default = "32768"
}

variable "vm_mem" {
  type    = string
  default = "4096"
}

variable "vm_nic_mac" {
  type    = string
  default = "9c0a914daaff"
}

#
# source blocks are generated from your builders; a source can be referenced in
# build blocks. A build block runs provisioner and post-processors on a
# source. Read the documentation for source blocks here:
# https://www.packer.io/docs/templates/hcl_templates/blocks/source
#
source "hyperv-iso" "openbsd-hv" {
  boot_command                     = ["S<enter><wait>", "dhclient hvn0<enter><wait5>", "ftp -o /install.conf http://{{ .HTTPIP }}:{{ .HTTPPort }}/install.conf<enter><wait>", "${var.vm_boot_setupsh}", "${var.vm_boot_cmd}"]
  boot_wait                        = "40s"
  communicator                     = "ssh"
  cpus                             = "${var.vm_cpus}"
  disk_size                        = "${var.vm_disk}"
  enable_dynamic_memory            = false
  enable_mac_spoofing              = true
  enable_secure_boot               = false
  enable_virtualization_extensions = true
  generation                       = 1
  guest_additions_mode             = "disable"
  headless                         = "${var.headless}"
  http_directory                   = "${var.http_dir}"
  iso_checksum                     = "${var.iso_checksum}"
  iso_url                          = "${var.iso_url}"
  mac_address                      = "${var.vm_nic_mac}"
  memory                           = "${var.vm_mem}"
  shutdown_command                 = "${var.shutdown_cmd}"
  skip_compaction                  = false
  ssh_password                     = "${var.ssh_user_pass}"
  ssh_port                         = "${var.ssh_port}"
  ssh_timeout                      = "${var.ssh_timeout}"
  ssh_username                     = "${var.ssh_user_name}"
  switch_name                      = "PackerSwitch"
  vm_name                          = "openbsd-hv"
}

source "qemu" "openbsd-qu" {
  boot_command        = ["<wait5>S<enter><wait5>", "dhclient vio0<enter><wait10>", "ftp -o /install.conf http://{{ .HTTPIP }}:{{ .HTTPPort }}/install-qemu.conf<enter><wait5>", "${var.vm_boot_setupsh}", "${var.vm_boot_cmd}"]
  boot_wait           = "40s"
  communicator        = "ssh"
  cpus                = "${var.vm_cpus}"
  disk_compression    = true
  disk_interface      = "virtio"
  disk_size           = "${var.vm_disk}"
  format              = "qcow2"
  headless            = "${var.headless}"
  http_directory      = "${var.http_dir}"
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
}

source "virtualbox-iso" "openbsd-vb" {
  boot_command         = ["S<enter><wait>", "dhclient em0<enter><wait5>", "ftp -o /install.conf http://{{ .HTTPIP }}:{{ .HTTPPort }}/install.conf<enter><wait>", "${var.vm_boot_setupsh}", "${var.vm_boot_cmd}"]
  boot_wait            = "20s"
  communicator         = "ssh"
  cpus                 = "${var.vm_cpus}"
  disk_size            = "${var.vm_disk}"
  guest_additions_mode = "disable"
  guest_os_type        = "OpenBSD_64"
  headless             = "${var.headless}"
  http_directory       = "${var.http_dir}"
  iso_checksum         = "${var.iso_checksum}"
  iso_url              = "${var.iso_url}"
  memory               = "${var.vm_mem}"
  shutdown_command     = "${var.shutdown_cmd}"
  ssh_password         = "${var.ssh_user_pass}"
  ssh_port             = "${var.ssh_port}"
  ssh_timeout          = "${var.ssh_timeout}"
  ssh_username         = "${var.ssh_user_name}"
  vboxmanage           = [["modifyvm", "{{ .Name }}", "--rtcuseutc", "on"], ["modifyvm", "{{ .Name }}", "--natdnshostresolver1", "on"]]
  vm_name              = "openbsd-vb"
  vrdp_bind_address    = "127.0.0.1"
  vrdp_port_max        = 12000
  vrdp_port_min        = 11000
}

source "vmware-iso" "openbsd-vw" {
  boot_command     = ["S<enter><wait>", "dhclient vio0<enter><wait5>", "ftp -o /install.conf http://{{ .HTTPIP }}:{{ .HTTPPort }}/install-qemu.conf<enter><wait>", "${var.vm_boot_setupsh}", "${var.vm_boot_cmd}"]
  boot_wait        = "30s"
  communicator     = "ssh"
  cpus             = "${var.vm_cpus}"
  disk_size        = "${var.vm_disk}"
  headless         = "${var.headless}"
  http_directory   = "${var.http_dir}"
  iso_checksum     = "${var.iso_checksum}"
  iso_url          = "${var.iso_url}"
  memory           = "${var.vm_mem}"
  shutdown_command = "${var.shutdown_cmd}"
  ssh_password     = "${var.ssh_user_pass}"
  ssh_port         = "${var.ssh_port}"
  ssh_timeout      = "7200s"
  ssh_username     = "${var.ssh_user_name}"
  vm_name          = "openbsd-vw"
  vmx_data = {
    "ethernet0.addressType"     = "generated"
    "ethernet0.networkName"     = "VM Network"
    "ethernet0.present"         = "TRUE"
    "ethernet0.wakeOnPcktRcv"   = "FALSE"
    "remotedisplay.vnc.enabled" = "TRUE"
    "vhv.enable"                = "TRUE"
  }
}

#
# a build block invokes sources and runs provisioning steps on them. The
# documentation for build blocks can be found here:
# https://www.packer.io/docs/templates/hcl_templates/blocks/build
#
build {
  sources = ["source.hyperv-iso.openbsd-hv", "source.qemu.openbsd-qu", "source.virtualbox-iso.openbsd-vb", "source.vmware-iso.openbsd-vw"]

  provisioner "shell" {
    expect_disconnect = false
    inline            = ["sudo /opt/update.sh"]
    pause_before      = "30s"
    timeout           = "10m0s"
  }

  provisioner "shell" {
    expect_disconnect = true
    inline            = ["sudo reboot"]
    pause_before      = "30s"
    timeout           = "6m0s"
  }

  provisioner "shell" {
    environment_vars  = ["iso_checksum=${var.iso_checksum}", "iso_url=${var.iso_url}"]
    execute_command   = "ksh '{{ .Path }}'"
    expect_disconnect = false
    pause_before      = "30s"
    scripts           = ["scripts/test.sh"]
  }

  post-processor "artifice" {
    files = ["output-openbsd-vb/openbsd-disk001.vmdk", "output-openbsd-vb/vbox-openbsd.ovf"]
  }
  post-processor "manifest" {
    output     = "boxes/manifest.json"
    strip_path = true
  }
  post-processor "vagrant" {
    keep_input_artifact  = true
    compression_level    = 9
    include              = ["templates/info.json", "scripts/test.sh"]
    output               = "boxes/OpenBSD.box"
    vagrantfile_template = "templates/vagrantfile.rb"
  }
  post-processor "checksum" {
    checksum_types = ["sha512"]
    output         = "boxes/{{ .BuildName }}.checksum"
  }
}
