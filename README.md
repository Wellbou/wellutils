<p align="right">
  <b>English</b> ·
  <a href="README.ru.md">Русский</a>
</p>

<div align="center">

  <img src="logo.png" alt="wellutils" width="128">

  # wellutils

  System and peripheral reporting tools for any Linux (Arch, Fedora,
  Debian, Ubuntu, Bodhi, openSUSE, Alpine, ...), with a
  zero-dependency PowerShell port for Windows.

  [![Language: Bash](https://img.shields.io/badge/Language-Bash-4EAA25?logo=gnubash&logoColor=white)](wellutils)
  [![Language: Python](https://img.shields.io/badge/Language-Python-3776AB?logo=python&logoColor=white)](wfetch_art.py)
  [![Platform: Linux](https://img.shields.io/badge/Platform-Linux-1793D1?logo=linux&logoColor=white)](install.sh)
  [![Platform: Windows](https://img.shields.io/badge/Platform-Windows-0078D6?logo=windows&logoColor=white)](windows/well.ps1)
  [![Version: 1.4.0](https://img.shields.io/badge/Version-1.4.0-22272E)](PKGBUILD)
  [![License: MIT](https://img.shields.io/badge/License-MIT-C16CFF)](LICENSE)

</div>

---

## What it is

Twelve single-file tools that report on what your machine is doing:
USB and PCI devices, block storage, memory, CPU topology, graphics,
kernel modules, temperatures, and peripherals. Every tool shares the
same CLI — same flags, same exit codes, same box-drawing output. A
launcher (`wellutils`) ties them together, and short aliases
(`wusb`, `wpci`, `wmem`, ...) are installed alongside.

The same interface ships as a single PowerShell file for Windows.
No WSL, no admin rights, no installers — data comes from CIM/WMI.

```
$ well fetch

  User: wellbou_@lor
  OS: Arch Linux (x86_64)
  Kernel: 7.1.6-arch1-1
  Uptime: 5h 14m · boot 2026-08-11 11:59
  CPU: Intel(R) Xeon(R) CPU E3-1230 V2 @ 3.30GHz
        4 cores / 8 threads @ 3500 MHz · load 5.79
  GPU: GP107 [GeForce GTX 1050 Ti] · 4 GiB
  Memory: 7 GiB / 7 GiB (93%)
  Resolution: 1600x900
```

## Contents

- [Install](#install)
- [Usage](#usage)
- [Tools](#tools)
- [Features](#features)
- [Dependencies](#dependencies)
- [License](#license)

## Install

### Any Linux (Arch, Fedora, Debian, Ubuntu, Bodhi, openSUSE, Alpine, ...)

One command — the installer detects your package manager (pacman,
dnf/yum, apt, zypper, apk, xbps, emerge), installs the optional
dependencies (hwdata ID database, lm-sensors, smartmontools,
dmidecode, ...) and drops the tools into `/usr/local/bin`:

```sh
curl -fsSL https://raw.githubusercontent.com/Wellbou/wellutils/main/install.sh | bash
```

Skip the dependency step with `--no-deps` (tools degrade gracefully:
no S.M.A.R.T., no sensor readings, no vendor-ID names). Use
`--prefix=/path` for a rootless install into your home directory.

### Arch Linux (package)

AUR helper install once the package is published, or build from this
repo:

```sh
yay -S wellutils      # or another AUR helper

# from the repository
makepkg -si
```

This installs the binaries, man pages, bash completion, and the
`/usr/share/wellutils` data files (JEDEC ID table, box/CLI helpers,
logo).

### Windows

Uses the PowerShell that ships with Windows — nothing to download
beyond a single file. Pick one:

```powershell
# PowerShell 5.1 or 7
irm https://raw.githubusercontent.com/Wellbou/wellutils/main/windows/install.ps1 | iex
```

```bash
# Git Bash / MSYS2
curl -fsSL https://raw.githubusercontent.com/Wellbou/wellutils/main/windows/install.sh | bash
```

This places `well.ps1` plus `well*.cmd` shims into
`%USERPROFILE%\.wellutils\bin` and adds it to your user PATH. Open a
new terminal, then:

```
well mem     | well fetch   | well hw
wellmem      | wellusb      | wellsensors   # per-tool shims
wmem -l en   | well usb --plain
```

Nothing runs as administrator; all data is read via CIM/WMI.

## Usage

Every tool shares one CLI:

```
tool [options]

  -h, --help               show help
  -V, --version            show version
      --lang ru|en|auto    output language (auto = system locale)
      --color always|auto|never
      --plain              plain text, no box drawing
      --box                force box drawing
      --no-emoji           drop emoji icons
      --json               machine-readable JSON on stdout
      --debug              shell tracing
```

Every tool can emit JSON — pipe it into `jq`, or save for a backend
service. Warnings and errors still go to stderr, so the JSON stream is
always clean:

```sh
wellhw --json | jq '.cpu.model'
wellsensors --json | jq -c '.summary'
wellblock 0 --json | jq '.disk.partitions'
```

Run a single tool directly, or go through the launcher:

```sh
wellhw --plain
wellutils hw --plain
wmem -l en
wellper --groups --json
```

`wellper` adds `--groups`, `--sections`, `--strict`, `--terse` (and
`--json`, now shared by every tool). `wellblock` takes an optional
`[N|device]` for a per-disk detail view with a S.M.A.R.T. health
report:

```sh
wblock 0          # first disk
wblock sdb        # by device node
wblock /dev/sdb
```

Every tool has a man page (`man wellper`) and bash completion.

## Tools

| Tool          | Report                                                        |
|---------------|---------------------------------------------------------------|
| `wellper`     | Peripherals: USB devices, displays, audio                     |
| `wellhw`      | Hardware: CPU, GPU, board, RAM with JEDEC-decoded vendors     |
| `wellmem`     | Memory from `/proc/meminfo`, with zram                       |
| `wellusb`     | USB device tree with hwdata IDS lookup                        |
| `wellpci`     | PCI devices with class descriptions                           |
| `wellblock`   | Block devices, partitions, mount points, S.M.A.R.T. health    |
| `wellcpu`     | CPU topology, frequencies, features, per-core load            |
| `wellgpu`     | Graphics: bus, vendor, driver, live NVIDIA stats              |
| `wellmod`     | Loaded kernel modules                                         |
| `wellsensors` | Temperatures and fans: hwmon, lm_sensors, nvidia-smi          |
| `wellfetch`   | System fetch with ASCII or PNG logo                           |
| `wellup`      | Check for system updates and apply them automatically         |

Short aliases are installed as commands: `wusb`, `wpci`, `wblock`,
`wcpu`, `wgpu`, `wmem`/`wram`/`wellram`, `wmod`, `wsensors`/`wtemp`,
`whw`, `wper`, `wfetch`, `wup`. The launcher accepts them too:
`wellutils wram --plain`.

`wellup` can also update the suite itself from GitHub:

```sh
wellup --self-update        # check and update wellutils
wellup --self-update --check  # only report the version difference
```

Note: `wellutils sensors` is intentionally not an alias — it would
shadow the `sensors` binary from lm_sensors. Use `wellsensors`.

## Features

- **USB classification by interface class.** Composite devices are
  classified by their interface classes (printer `07`, storage `08`,
  webcam `0e`, network `02`, audio `01/04`, data `06`, hub `09`), so
  printers, webcams and gamepads are identified correctly even when
  `bDeviceClass` reports `0x00` or `0xEF`.
- **JEDEC RAM vendor decoding.** `wellhw` resolves raw JEP106
  manufacturer codes from dmidecode (e.g. `8313` → Golden Empire).
  The ID table ships as `/usr/share/wellutils/jedec.sh`.
- **No root required.** Everything is read from sysfs and `/proc`.
  dmidecode and decode-dimms are used only when passwordless sudo is
  available.
- **S.M.A.R.T. health in `wellblock`.** The per-disk view checks
  overall health and flags failing critical attributes (reallocated
  sectors, pending and uncorrectable errors, CRC errors) in colour.
- **Same options everywhere.** One CLI, one output style, one set of
  exit codes — on Linux and Windows alike.

## Dependencies

**Required:** `bash`, `python`, `coreutils`, `procps-ng` (on
Debian/Ubuntu the package names differ: `procps`, `python3`).

**Optional:** `pciutils` (PCI descriptions), `usbutils` (USB ID
database), `smartmontools` (wellsensors and wellblock S.M.A.R.T.),
`nvme-cli` (NVMe temperatures), `dmidecode` + `i2c-tools` (RAM detail
via decode-dimms), `util-linux` (lscpu for wellcpu). The `install.sh`
installer picks the correct package names for your distribution.

## License

MIT, except the JEDEC JEP106 vendor table (`jedec.sh`), which is
extracted from i2c-tools `decode-dimms` (GPL-2.0, (c) the i2c-tools
authors). See `LICENSE` for full attribution.
