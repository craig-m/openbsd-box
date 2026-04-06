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


Write-Host "[*] Building OpenBSD box."
Write-Host "[*] type: $packbldtype2"
$scriptloc = Get-Location
Write-Host "[*] located in: $scriptloc"

# vars
$packerinput = "openbsd.pkr.hcl"
$env:PACKER_LOG = 2
$env:PKR_VAR_version="v7.1_b001"

# Generate a unique build ID and output directory
$buildId = $env:PKR_VAR_version + "_" + (Get-Date -Format "yyyyMMdd_HHmmss")
$buildDir = "builds\$buildId"
New-Item -ItemType Directory -Force -Path $buildDir | Out-Null

$env:PACKER_LOG_PATH = "$buildDir\packer.log"
$env:PKR_VAR_output_dir = "..\$buildDir"

Write-Host "[*] build ID: $buildId"
Write-Host "[*] output dir: $buildDir"


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

Set-Location ../

# list build files
if (Test-Path "$buildDir\OpenBSD.box") {
    Write-Host "------ box files ------"
    Get-ChildItem $buildDir
} else {
    Write-Host "Box did not get created."
    exit 1;
}

Write-Host ""
Write-Host "[*] Build complete. Box stored in: $buildDir"
Write-Host "[*] To start the VM run:  .\run.ps1 $packbldtype $buildId"
Write-Host ""
Write-Host "[*] finished build script."