param (
    [string]$packbldtype = $( Read-Host "Select type use 'hv' or 'vb':" )
)
$packbldtype2 = -join('openbsd-', "$packbldtype");

#requires -runasadministrator

Write-Host "[*] Building OpenBSD box."
Write-Host "[*] type: $packbldtype2"

# vars
$packerinput = "openbsd.json"
#$packerinput = "openbsd.json.pkr.hcl"
$env:PACKER_LOG = 2
$env:PACKER_LOG_PATH = "packer.log"

# Validate packer input
try {
    Start-Process -NoNewWindow -Wait -ArgumentList 'validate', '-syntax-only', "$packerinput" packer.exe
} catch {
    Write-Host "ERROR validating $packerinput"
    exit 1;
}

# Build the box
try {
    Start-Process -NoNewWindow -Wait -ArgumentList 'build', "-only=$packbldtype2", "$packerinput" packer.exe
} catch {
    Write-Host "ERROR building"
    exit 1;
}

if (Test-Path ./boxes/OpenBSD.box) {
    Write-Host "------ box files ------"
    Get-ChildItem .\boxes\
} else {
    Write-Host "Box did not get created."
    exit 1;
}

# Start Vagrant VM
try {
    Start-Process -NoNewWindow -Wait -ArgumentList "up" vagrant.exe
} catch {
    Write-Host "ERROR starting VM"
    exit 1;
}

Write-Host "[*] finished build script."