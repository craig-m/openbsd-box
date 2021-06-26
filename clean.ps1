#requires -runasadministrator

Write-Host "[*] cleaning up"
# note: will not remove openbsd install iso from packer_cache

vagrant destroy -f
vagrant box remove openbsd -f

Remove-Item -Force -Recurse -ErrorAction Ignore output-openbsd-*
Remove-Item -Force -ErrorAction Ignore boxes/manifest.json
Remove-Item -Force -ErrorAction Ignore boxes/manifest.json.lock
Remove-Item -Force -ErrorAction Ignore boxes/OpenBSD.box
Remove-Item -Force -ErrorAction Ignore boxes/openbsd-*
Remove-Item -Force -ErrorAction Ignore packer.log

Write-Host "[*] clean finished"