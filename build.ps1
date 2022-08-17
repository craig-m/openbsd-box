param (
    [string]$packbldtype = $( Read-Host "Select type use 'hv' or 'vb':" )
)

#requires -runasadministrator


# check input
If ( $packbldtype -eq 'hv' )
{
    # HyperV
    $packbldtype2 = "hyperv-iso.openbsd-hv"
} ElseIf ( $packbldtype -eq 'vb' )
{
    # VirtualBox
    $packbldtype2 = "virtualbox-iso.openbsd-vb"
} Else {
    Write-Host "[*] ERROR: wrong input"
    exit 1
}


Write-Host "[*] Building and starting OpenBSD box."
Write-Host "[*] type: $packbldtype2"
$scriptloc = Get-Location
Write-Host "[*] located in: $scriptloc"

# vars
$packerinput = "openbsd.pkr.hcl"
$env:PACKER_LOG = 2
$env:PACKER_LOG_PATH = "packer.log"
$env:PKR_VAR_version="v7.1_b001"


#
# Packer
#
Set-Location packer/

# Validate packer input
try {
    Start-Process -NoNewWindow -Wait -ArgumentList 'validate', '-syntax-only', "$packerinput" packer
} catch {
    Write-Host "ERROR validating $packerinput"
    exit 1;
}

# Build the box
try {
    Start-Process -NoNewWindow -Wait -ArgumentList 'build', "-only=$packbldtype2", "-parallel-builds=1", "$packerinput" packer
} catch {
    Write-Host "ERROR building"
    exit 1;
}

# list build files
if (Test-Path ./boxes/OpenBSD.box) {
    Write-Host "------ box files ------"
    Get-ChildItem .\boxes\
} else {
    Write-Host "Box did not get created."
    exit 1;
}

# add box to local vagrant cache
try {
    Start-Process -NoNewWindow -Wait -ArgumentList 'box', "add", "boxes/OpenBSD.box", "--name", "OpenBSD.box" vagrant
} catch {
    Write-Host "ERROR adding box"
    exit 1;
}

Set-Location ../


#
# Vagrant
#
Set-Location vagrant/

# Validate Vagrantfile
try {
    Start-Process -NoNewWindow -Wait -ArgumentList "validate", ".\Vagrantfile" vagrant
} catch {
    Write-Host "ERROR in Vagrantfile"
    exit 1;
}

# Start Vagrant VM
try {
    Start-Process -NoNewWindow -Wait -ArgumentList "up" vagrant
} catch {
    Write-Host "ERROR starting VM"
    exit 1;
}
try {
    Start-Process -NoNewWindow -Wait -ArgumentList "ssh", "--command", "uptime", "--machine-readable" vagrant
} catch {
    Write-Host "ERROR SSHing into VM"
    exit 1;
}

Write-Host "[*] finished build script."