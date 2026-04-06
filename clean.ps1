#requires -runasadministrator

Write-Host "[*] cleaning up"
# note: will not remove openbsd install iso from packer_cache

Set-Location ./vagrant/
Start-Process -NoNewWindow -Wait -ArgumentList "destroy", "-f" vagrant
Start-Process -NoNewWindow -Wait -ArgumentList "box", "remove", "OpenBSD.box", "-f" vagrant
Set-Location ../

Set-Location ./packer/
Remove-Item -Force -Recurse -ErrorAction Ignore output-openbsd-*
Remove-Item -Force -ErrorAction Ignore packer.log
Set-Location ../

Remove-Item -Force -Recurse -ErrorAction Ignore builds\

Write-Host "[*] clean finished"