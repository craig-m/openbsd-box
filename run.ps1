param (
    [string]$packbldtype = $( Read-Host "Select type use 'hv' or 'vb':" ),
    [string]$buildId = ""
)

#requires -runasadministrator


# check input
If ( $packbldtype -eq 'hv' )
{
    # HyperV
    Write-Host "[*] HyperV provider"
} ElseIf ( $packbldtype -eq 'vb' )
{
    # VirtualBox
    Write-Host "[*] VirtualBox provider"
} Else {
    Write-Host "[*] ERROR: wrong input. Use 'hv' or 'vb'."
    exit 1
}


Write-Host "[*] Starting OpenBSD VM from a build."

# Select build: use provided buildId or default to latest
If ( $buildId -ne "" )
{
    Write-Host "[*] Using specified build: $buildId"
} Else {
    If ( -Not (Test-Path "builds") -or ((Get-ChildItem "builds" -Directory).Count -eq 0) )
    {
        Write-Host "[.] ERROR: No builds found in builds\. Run build.ps1 first."
        exit 1
    }
    $buildId = (Get-ChildItem "builds" -Directory | Sort-Object LastWriteTime -Descending | Select-Object -First 1).Name
    Write-Host "[*] Using latest build: $buildId"
}

$buildDir = "builds\$buildId"

If ( -Not (Test-Path "$buildDir\OpenBSD.box") )
{
    Write-Host "[.] ERROR: Box not found at $buildDir\OpenBSD.box"
    Write-Host "[.] Available builds:"
    Get-ChildItem "builds" -Directory -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending
    exit 1
}


#
# Vagrant
#

# add box to local vagrant cache
try {
    Start-Process -NoNewWindow -Wait -ArgumentList 'box', "add", "$buildDir\OpenBSD.box", "--force", "--name", "OpenBSD.box" vagrant
} catch {
    Write-Host "ERROR adding box"
    exit 1;
}

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

Set-Location ../

Write-Host "[*] finished run script."
