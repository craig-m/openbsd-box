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

# You can install Powershell on MacOS and Linux, but this script only works on Windows
#
# https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell

Write-Host "[*] Building OpenBSD box."
Write-Host "[*] type: $packbldtype2"
$scriptloc = Get-Location
Write-Host "[*] located in: $scriptloc"

# vars
$packerinput = "openbsd.pkr.hcl"
$env:PACKER_LOG = 2
$env:PACKER_LOG_PATH = "packer.log"

# Validate packer input
try {
    Start-Process -NoNewWindow -Wait -ArgumentList 'validate', '-syntax-only', "$scriptloc/$packerinput" packer.exe
} catch {
    Write-Host "ERROR validating $packerinput"
    exit 1;
}

# Build the box
try {
    Start-Process -NoNewWindow -Wait -ArgumentList 'build', "-only=$packbldtype2", "-parallel-builds=1", "$scriptloc/$packerinput" packer.exe
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

# Validate Vagrantfile
try {
    Start-Process -NoNewWindow -Wait -ArgumentList "validate", ".\Vagrantfile" vagrant.exe
} catch {
    Write-Host "ERROR in Vagrantfile"
    exit 1;
}

# Start Vagrant VM
try {
    Start-Process -NoNewWindow -Wait -ArgumentList "up" vagrant.exe
} catch {
    Write-Host "ERROR starting VM"
    exit 1;
}
try {
    vagrant ssh --command "uptime" --machine-readable
} catch {
    Write-Host "ERROR SSHing into VM"
    exit 1;
}

Write-Host "[*] finished build script."