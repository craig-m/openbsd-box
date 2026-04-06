# Regression Testing Across OpenBSD Versions

This document describes how to use openbsd-box to run regression tests against
multiple OpenBSD releases, covering the last five years of stable releases.

---

## Supported OpenBSD versions

| Version | Release date | Status |
|---------|-------------|--------|
| 7.8 | October 2025 | ✅ Default (checksum set) |
| 7.7 | April 2025 | ⚠ Checksum needed |
| 7.6 | October 2024 | ⚠ Checksum needed |
| 7.5 | April 2024 | ⚠ Checksum needed |
| 7.4 | October 2023 | ⚠ Checksum needed |
| 7.3 | April 2023 | ⚠ Checksum needed |
| 7.2 | October 2022 | ⚠ Checksum needed |
| 7.1 | April 2022 | ⚠ Checksum needed |
| 7.0 | October 2021 | ⚠ Checksum needed |

OpenBSD releases a new stable version approximately every six months.
All releases since October 2021 fall within the five-year window.

---

## Adding checksums for older versions

Before building a version other than 7.8, you must fill in the SHA256 checksum
in `packer/versions.conf`.

1. Find an official OpenBSD mirror (see https://www.openbsd.org/ftp.html).
2. Download the SHA256 file for the version you want:
   ```sh
   curl -O https://mirrors.openbsd.org/pub/OpenBSD/7.6/amd64/SHA256
   grep install76.iso SHA256
   ```
3. Copy the 64-character hex checksum into `packer/versions.conf`:
   ```sh
   ISO_SHA256_76="<paste-checksum-here>"
   ```

---

## Building a specific version

```sh
# Build OpenBSD 7.6 with QEMU (recommended on Linux)
./build.sh -qu -V 7.6

# Build OpenBSD 7.4 with VirtualBox
./build.sh -vb -V 7.4

# Default (7.8) – no -V flag needed
./build.sh -qu
```

Each build creates a timestamped directory under `builds/`:
```
builds/
├── v7.8_b001_20250101_120000/
│   ├── OpenBSD.box
│   ├── serial.log
│   └── packer.log
├── v7.6_b001_20250101_130000/
│   ├── OpenBSD.box
│   ├── serial.log
│   └── packer.log
└── ...
```
Multiple builds coexist; you can switch between them with `run.sh`.

---

## Running a specific version

```sh
# Start the latest build
./run.sh -qu

# Start a specific build
./run.sh -qu v7.6_b001_20250101_130000
```

---

## Scripted regression matrix

To test a piece of software or a patch across all supported versions,
write a loop around the build and run scripts.

```sh
#!/usr/bin/env sh
# regression-matrix.sh – build and test all supported OpenBSD versions

. ./packer/versions.conf   # load OPENBSD_SUPPORTED_VERSIONS

for VER in ${OPENBSD_SUPPORTED_VERSIONS}; do
    echo "=== Testing OpenBSD ${VER} ==="

    # Build (skip versions with missing checksums – build.sh will error and continue)
    if ./build.sh -qu -V "${VER}"; then
        BUILD_ID=$(ls -1t builds/ | head -n 1)

        # Start VM
        ./run.sh -qu "${BUILD_ID}"

        # Run your test suite inside the VM
        cd vagrant
        vagrant ssh --command "/bin/ksh /opt/vmcode/my-tests.sh" || true
        vagrant destroy -f
        cd ..

        echo "=== ${VER}: DONE ==="
    else
        echo "=== ${VER}: SKIPPED (checksum not set or build failed) ==="
    fi
done
```

Place your test script in `vagrant/vmcode/` so it is rsync'd into the VM at
`/opt/vmcode/`.

---

## What packer/test.sh validates

After every Packer build, `packer/test.sh` runs inside the new VM and checks:

* `/opt/.setup.sh` exists (setup script completed)
* `pkg_check` reports no package database errors
* Services are running: `sshd`, `ntpd`, `cron`, `smtpd`, `pflogd`, `xenodm`
* Packages are installed: `rsync`, `curl`
* `/etc/rc.firsttime` has been removed (normal boot completed)

This gives confidence that the base image is healthy before it is packaged.

---

## Customising the test suite

To add your own regression tests:

1. Place scripts in `vagrant/vmcode/`:
   ```
   vagrant/vmcode/
   └── my-tests.sh
   ```

2. After `vagrant up`, SSH in and run them:
   ```sh
   vagrant ssh
   /bin/ksh /opt/vmcode/my-tests.sh
   ```

3. Or run non-interactively from `vagrant.sh`:
   ```ksh
   # vagrant/vagrant.sh
   ksh /opt/vmcode/my-tests.sh | tee /tmp/regression.log
   ```

---

## Preserving artefacts between runs

Each build stores all relevant files in its timestamped `builds/` directory:
* `serial.log` – console output during build
* `packer.log` – full Packer log

During runtime, `run.sh` sets `VAGRANT_SERIAL_LOG` to
`builds/<BUILD_ID>/serial-runtime.log`, so any crash during testing is
captured alongside the build artefacts for later analysis.

---

## References

* OpenBSD stable releases: https://www.openbsd.org/stable.html
* OpenBSD mirrors: https://www.openbsd.org/ftp.html
* OpenBSD errata: https://www.openbsd.org/errata.html
