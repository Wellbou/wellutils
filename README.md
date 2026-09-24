<p align="right">
  <b>English</b> ·
  <a href="README.ru.md">Русский</a>
</p>

<div align="center">

  <img src="logo.png" alt="wellutils" width="128">

  # wellutils

  System and peripheral reporting tools for any Linux (Arch, Fedora,
  Debian, Ubuntu, Bodhi, openSUSE, Alpine, ...), plus a
  zero-dependency PowerShell port for Windows.

  [![Language: Bash](https://img.shields.io/badge/Language-Bash-4EAA25?logo=gnubash&logoColor=white)](wellutils)
  [![Language: Python](https://img.shields.io/badge/Language-Python-3776AB?logo=python&logoColor=white)](src/wfetch_art.py)
  [![Platform: Linux](https://img.shields.io/badge/Platform-Linux-1793D1?logo=linux&logoColor=white)](install.sh)
  [![Platform: Windows](https://img.shields.io/badge/Platform-Windows-0078D6?logo=windows&logoColor=white)](windows/well.ps1)
  [![Version: 1.4.0-54](https://img.shields.io/badge/Version-1.4.0--54-22272E)](PKGBUILD)
  [![License: MIT](https://img.shields.io/badge/License-MIT-C16CFF)](src/LICENSE)

</div>

---

## What it is

Sixteen single-file tools that tell you what your machine is doing: USB
and PCI devices, block storage, memory, CPU topology, graphics, kernel
modules, temperatures, peripherals, network, power, a health
aggregator and an offline HTML report. On Linux every tool shares the
same core CLI - the same common flags, the same exit codes, the same
box-drawing output. A launcher (`wellutils`) ties them together, and
short aliases (`wusb`, `wpci`, `wmem`, ...) are installed alongside.

A smaller version of the same interface ships as a single PowerShell
file for Windows. No WSL, no admin rights, no installers - data comes
from CIM/WMI. To be honest, the Windows port is quite basic: it has no
`--json`, `--short` or `--html`, so on Windows you mostly just look at
the output:

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
- [Docs](#docs)
- [Scripting with --json](#scripting-with---json)
- [Features](#features)
- [Dependencies](#dependencies)
- [License](#license)

## Install

### Any Linux (Arch, Fedora, Debian, Ubuntu, Bodhi, openSUSE, Alpine, ...)

One command - the installer detects your package manager (pacman,
dnf/yum, apt, zypper, apk, xbps, emerge), installs the dependencies
(hwdata ID database, lm-sensors, smartmontools, dmidecode, ...) and
drops the tools into `/usr/local/bin`:

```sh
curl -fsSL https://raw.githubusercontent.com/Wellbou/wellutils/main/install.sh | bash
```

No `curl`? `wget` works just as well:

```sh
wget -qO- https://raw.githubusercontent.com/Wellbou/wellutils/main/install.sh | bash
```

> **Bare Alpine:** the base image ships no `bash`, and `install.sh`
> needs it (plus `curl` or `wget`). Install it first: `apk add bash curl`.

Skip the dependency step with `--no-deps` (tools degrade gracefully:
no S.M.A.R.T., no sensor readings, no vendor-ID names).

- **Rootless:** `./install.sh --prefix=$HOME/.local` puts everything
  into your home directory, no sudo needed. Make sure `~/.local/bin` is
  in your `PATH`.
- **Termux (Android):** works without root; the installer uses `pkg`
  and installs into Termux's own `$PREFIX`. Some data (S.M.A.R.T.,
  dmidecode, part of sysfs) is simply not visible to apps on Android,
  so those sections stay empty.
- **NixOS:** the installer copies files only and defaults to
  `~/.local`; add the dependencies you want (`smartmontools`,
  `pciutils`, `lm_sensors`, ...) through your Nix configuration.

### From source (git clone)

Clone the repository and run the same installer against the clone:

```sh
git clone https://github.com/Wellbou/wellutils.git
cd wellutils
./install.sh
```

All scripts live in `src/`, so you can also run a tool straight from
the clone without installing it:

```sh
./src/wellcpu --short
./src/welldoctor --json
```

### Arch Linux (package)

Build from this repository:

```sh
makepkg -si
```

This installs the binaries, man pages, bash completion, and the
`/usr/share/wellutils` data files (JEDEC ID table, box/CLI helpers,
logo).

### Windows

Uses the PowerShell that ships with Windows - exactly one file to
download, nothing else. Pick one:

```powershell
# PowerShell 5.1 or 7
irm https://raw.githubusercontent.com/Wellbou/wellutils/main/windows/install.ps1 | iex
```

```bash
# Git Bash / MSYS2
curl -fsSL https://raw.githubusercontent.com/Wellbou/wellutils/main/windows/install.sh | bash
```

This places `well.ps1` plus `well*.cmd` shims into
`%USERPROFILE%\.wellutils\bin` and adds the directory to your user
PATH. Open a new terminal, then:

```
well mem     | well fetch   | well hw
wellmem      | wellusb      | wellsensors   # per-tool shims
wmem -l en   | well usb --plain
```

Nothing runs as administrator; all data is read via CIM/WMI.

## Usage

Every Linux tool shares one core CLI (a few tools add their own flags
on top; `--help` of each tool lists them):

```
tool [options]

  -h, --help               show help
  -V, --version            show version
      --lang ru|en|auto    output language (auto = system locale)
      --color always|auto|never
      --plain              plain text, no box drawing
      --box                force box drawing
      --no-emoji           drop emoji icons
      --emoji               force emoji icons
      --json               machine-readable JSON on stdout
      --short              one-line status (only the "live" tools)
      --html               standalone HTML page
      --debug              shell tracing

Exit codes: 0 ok, 2 bad CLI, 3 runtime error
(welldoctor: 0 healthy, 1 warnings, 2 critical, 3 runtime error)
```

Every tool can emit JSON - pipe it into `jq`, or save it for an
integration service. Warnings and errors still go to stderr, so the
JSON stream is always clean:

```sh
wellhw --json | jq '.cpu.model'
wellsensors --json | jq -c '.summary'
wellblock 0 --json | jq '.disk.partitions'
```

Run a tool directly, or go through the launcher:

```sh
wellhw --plain
wellutils hw --plain
wmem -l en
wellper --groups --json
```

`wellper` also has `--groups`, `--sections`, `--strict`, `--terse`. `wellblock`
takes an optional `[N|device]` for a per-disk detail view with a
S.M.A.R.T. health report:

```sh
wblock 0          # first disk
wblock sdb        # by device node
wblock /dev/sdb
```

Every tool has a man page (`man wellper`) and bash, zsh and fish
completions.

## Tools

| Tool          | Report                                                        |
|---------------|---------------------------------------------------------------|
| `wellper`     | Peripherals: USB devices, displays, audio                     |
| `wellhw`      | Hardware: CPU, GPU, board, RAM with JEDEC decoding            |
| `wellmem`     | Memory from `/proc/meminfo`, with zram                       |
| `wellusb`     | USB device tree with hwdata ID lookup                         |
| `wellpci`     | PCI devices with class descriptions                           |
| `wellblock`   | Block devices, partitions, mount points, S.M.A.R.T. health    |
| `wellcpu`     | CPU topology, frequencies, features, per-core load            |
| `wellgpu`     | Graphics: bus, vendor, driver, live NVIDIA stats              |
| `wellmod`     | Loaded kernel modules                                         |
| `wellsensors` | Temperatures and fans: hwmon, lm_sensors, nvidia-smi          |
| `wellfetch`   | System fetch with ASCII or PNG logo                           |
| `wellup`      | Check for system updates and apply them automatically         |
| `wellnet`     | Offline network overview: interfaces, Wi-Fi, routes, ports    |
| `wellpower`   | Battery wear, cycles, charge thresholds, power profiles       |
| `welldoctor`  | Health aggregator for cron: SMART, temps, units, disk         |
| `whtml`       | Offline HTML system report, CLI-styled.                       |

Short aliases are installed as commands: `wusb`, `wpci`, `wblock`,
`wcpu`, `wgpu`, `wmem`/`wram`/`wellram`, `wmod`, `wsensors`/`wtemp`,
`whw`, `wper`, `wfetch`, `wup`, `wnet`, `wpower`/`wbatt`,
`wdoc`/`wdoctor`. `whtml` answers to `wellutils html` and
`wellutils report` as well. The launcher accepts all of them:
`wellutils wram --plain`.

`wellup` asks for confirmation before applying updates; pass `--yes`
to skip the prompt (for scripts and cron). It can also update the
suite itself from GitHub:

```sh
wellup --check                # only list available updates
wellup                        # list, then ask before applying
wellup --yes                  # apply without confirmation
wellup --self-update          # check and update wellutils
wellup --self-update --check  # only report the version difference
```

## Docs

- [**docs/SCRIPTING.md**](docs/SCRIPTING.md) - the `--json` tutorial, built
  around `whtml`; also covers per-core load, GPU temps, cron watchdogs and
  inventory diffs.
- [**SAMPLES.md**](SAMPLES.md) - real, unedited output of every tool from
  the Wellbou machine (i.e. mine): you can look in advance at what each
  command prints.

## Status-bar mode

Every "live" (no idea what else to call it) tool prints one line with
`--short`, made for i3blocks, waybar, polybar and tmux:

```sh
wellcpu --short      # 17%
wellmem --short      # 1.9/3.8GiB
wellsensors --short  # 52°C
wellgpu --short      # 53°C 36%
wellpower --short    # 85%+ (wear 7%)
```

Example waybar snippet: `custom-cpu = { exec: "wellcpu --short"; interval: 3; }`

## Scripting with --json

Every report tool can emit one machine-readable JSON document
(`--json`) - and `whtml`, I hope, motivates you to learn the format. It
doesn't read sysfs or `/proc` itself; it just runs the other tools with
`--json`, joins their output, and makes one HTML page from it. Whatever
you want to script, I think you'll manage with wellutils:

```sh
# this is how whtml works - roughly, obviously, just showing the command
whtml --output ~/report.html
```

You can just use the same thing directly:

```sh
wellhw --json | jq -r '.cpu.model'      # CPUs on this box
wellcpu --json | jq -r '.load[].usage_percent'   # per-core load
```

All tools share the envelope `{ "tool", "version", "date", ... }`. The
full tutorial - watchdogs, cron checks, inventory diffs - lives in
[`docs/SCRIPTING.md`](docs/SCRIPTING.md), and the real output of every
tool is in [SAMPLES.md](SAMPLES.md).

## New in 1.4.0-54

This one is mostly about making wellutils work on machines other than
mine. I tried to go through as many odd setups as I could; some of them
I could only check on paper, so if something still breaks for you,
please tell me.

- Frames and emoji: the width engine was rewritten. Frames are now
  straight on every tool (wide and narrow emoji, Cyrillic, CJK), and
  tools use the real terminal width instead of guessing.
- Runs on more systems: busybox, Alpine/musl, old Debian with mawk,
  Termux on Android, ARM boards, Asahi Macs and POWER machines. CPU
  and board names are read from the device tree where there is no
  SMBIOS.
- SMBIOS junk like "To Be Filled By O.E.M." or "Not Specified" is
  filtered out instead of being printed as if it were a real name.
- JEDEC decoding fix: the parity bit was handled wrong, so Samsung,
  SK Hynix, Kingston, Crucial and other vendors were not decoded. They
  are now.
- `wellusb` now scans USB devices natively from sysfs.
- `welldoctor` no longer raises a false "S.M.A.R.T. FAILED": it used to
  match a column header of the smartctl table. It also treats systemd
  inside containers as unavailable instead of "all fine", and `--short`
  now returns the same 0/1/2 exit codes as the other modes.
- Many crash fixes: `wellnet` on laptops with Wi-Fi, `wellmem` with ECC
  memory, `wellfetch --all`, and more.
- Installer fixes: `parse.sh` is installed now (tools failed to start
  without it), Termux and NixOS support, correct completion paths,
  `curl` or `wget`.
- `whtml`: all values are escaped properly (a strange device name can
  no longer break the page), write errors are reported with exit code
  3, and it runs noticeably faster.
- Completions are generated from each tool's `--help`, so they finally
  match the real flags; the launcher gets completions too.
- Big speedups overall: far fewer subprocesses in loops, which is very
  noticeable on slow netbooks and SBCs.

## New in 1.4.0-47

- `wellutils` launcher now lists `whtml` as a top-level command (it was
  hiding behind the `report` alias).
- New [**docs/SCRIPTING.md**](docs/SCRIPTING.md) - the `--json` contract
  on the living `whtml` example.
- `whtml --ami` - AMI BIOS setup-utility mode: xb-16 palette, Perfect DOS VGA
  font, F1/F9/F10/Esc hotkeys. It's a bit unneeded, but at least I no longer
  have an unstoppable urge to build something like that. And it's cool, isn't
  it?
- `whtml` - fully offline HTML report with CLI style.
- `wellnet` - fully offline network overview: interfaces, addresses, Wi-Fi,
  routes, ports, traffic counters and connection-type detection.
- `wellpower` - battery wear, cycles, charge thresholds, power profiles.
- `welldoctor` - health aggregator for cron (SMART, temperatures, failed
  units, disk usage, pacnew leftovers, orphans); exit code 0/1/2.
- `wellhw --snapshot [file]` / `--diff [file]` - "what changed since last
  week". It'll come in handy somewhere. I hope.
- `wellup --pacnew` - list leftover config files.
- `--html` on every report tool - ready-made HTML report page.
- Distro ASCII logos in wellfetch (`--png` brings back the pixel logo).
- zsh and fish completions alongside bash.

Note: `wellutils sensors` works as an alias for `wellsensors`. Other
aliases: `wsensors`, `wtemp`. See wellutils(1) for the full list.

## Features

- **USB classification by interface class.** Composite devices are
  classified by their interface classes (printer `07`, storage `08`,
  webcam `0e`, network `02`, audio `01/04`, data `06`, hub `09`), so
  printers, webcams and gamepads are identified correctly even when
  `bDeviceClass` reports `0x00` or `0xEF`.
- **JEDEC RAM vendor decoding.** `wellhw` resolves raw JEP106 codes
  from dmidecode (e.g. `8313` -> Golden Empire). The ID table ships as
  `/usr/share/wellutils/jedec.sh`.
- **No root required.** Everything is read from sysfs and `/proc`.
  dmidecode and decode-dimms are used only when passwordless sudo is
  available.
- **S.M.A.R.T. health in `wellblock`.** The per-disk view checks
  overall health and flags failing critical attributes (reallocated
  sectors, pending and uncorrectable errors, CRC errors) in colour.
- **Same core options on every Linux tool.** One CLI, one output
  style, one set of exit codes. The Windows port follows the same look
  and the basic flags, but has no `--json`, `--short` or `--html`.

## Dependencies

**Required:** `bash` 4.0 or newer, `coreutils` (busybox is fine),
`procps-ng` (`procps` on Debian/Ubuntu). For the installer: `curl` or
`wget`.

**Python is optional:** only `whtml` and the PNG logo of `wellfetch`
(`--png`) need `python3`. Everything else is plain bash.

**Optional:** `pciutils` (PCI descriptions), `hwdata` (USB ID
database), `smartmontools` (wellsensors and wellblock S.M.A.R.T.),
`nvme-cli` (NVMe temperatures), `dmidecode` + `i2c-tools` (RAM detail
via decode-dimms), `util-linux` (lscpu for wellcpu). The `install.sh`
installer picks the right package names for your distribution.

## License

MIT, except the JEDEC JEP106 vendor table (`jedec.sh`), which is
extracted from i2c-tools `decode-dimms` (GPL-2.0, (c) the i2c-tools
authors). See `LICENSE` for full attribution.
