# wellutils

A suite of colourful system and peripheral reporting tools for Arch Linux —
and a lightweight, zero-dependency PowerShell port for Windows 10/11.

## Tools

| Tool          | Purpose                                                    |
|---------------|------------------------------------------------------------|
| `wellper`     | Peripheral report: USB devices, displays, audio            |
| `wellhw`      | Hardware report: CPU, GPU, board, RAM (JEDEC-decoded), ... |
| `wellmem`     | Memory overview from `/proc/meminfo`                       |
| `wellusb`     | USB device listing with hwdata IDS lookup                  |
| `wellpci`     | PCI device listing with class descriptions                 |
| `wellblock`   | Block devices, partitions, mount points                    |
| `wellcpu`     | CPU topology, frequencies, features, per-core load         |
| `wellgpu`     | Graphics adapters: bus, vendor, driver, live NVIDIA stats  |
| `wellmod`     | Loaded kernel modules                                      |
| `wellsensors` | Temperatures and fans (hwmon / lm_sensors / nvidia-smi)    |
| `wellfetch`   | System fetch (ASCII/PNG logo, distro info)                 |
| `wellutils`   | Launcher: `wellutils hw`, `wellutils mem`, ...             |

Short aliases are installed as commands (symlinks): `wusb`, `wpci`,
`wblock`, `wcpu`, `wgpu`, `wmem`/`wram`/`wellram`, `wmod`,
`wsensors`/`wtemp`, `whw`, `wper`, `wfetch` — e.g. `wtemp --plain`. The
launcher also accepts them as arguments: `wellutils wram --plain`. Note:
`wellutils sensors` is intentionally *not* an alias — it would shadow
the `sensors` binary from lm_sensors.

`wellblock` takes an optional argument `[N|device]` to show a detail
view for a single disk: partitions and a S.M.A.R.T. health report
(overall status plus the critical attributes table) read via
`smartctl` with passwordless sudo when available. Example:
`wblock 0` (first disk), `wblock sdb` or `wblock /dev/sdb`.

## Install

### Linux (Arch)

AUR: `yay -S wellutils` (once published), or build locally:

```sh
makepkg -si
```

### Windows

No WSL, no admin rights, no downloads beyond a single file: uses the
PowerShell that ships with Windows. Pick one:

```powershell
# PowerShell (5.1 or 7) — recommended
irm https://raw.githubusercontent.com/Wellbou/wellutils/main/windows/install.ps1 | iex

# Git Bash / MSYS2
curl -fsSL https://raw.githubusercontent.com/Wellbou/wellutils/main/windows/install.sh | bash
```

Installs `well.ps1` plus `well*.cmd` shims into `%USERPROFILE%\.wellutils\bin`
and adds it to your user PATH. Open a NEW terminal, then:

```
well mem    | well fetch  | well hw
wellmem     | wellusb     | wellsensors   # per-tool shims
wmem -l en  | well usb --plain
```

All tools read data via CIM/WMI — nothing to install, nothing runs as
administrator.

## Usage

Every tool shares the same CLI:

```
tool [options]
  -h, --help
  -V, --version
      --lang ru|en|auto      output language
      --color always|auto|never
      --plain                plain text, no box drawing
      --box                  force box drawing
      --no-emoji             drop emoji icons
      --debug                shell tracing
```

`wellper` additionally supports `--groups`, `--sections`, `--strict`,
`--terse` and `--json`. Launcher: `wellutils <tool> [args...]`, e.g.
`wellutils hw --plain`.

## Features worth noting

- **USB classification**: composite devices are classified by their
  interface classes (printer 07, storage 08, webcam 0e, network 02, audio
  01/04, data 06, hub 09), so printers, webcams and gamepads are detected
  correctly even when `bDeviceClass` is 0x00/0xEF.
- **JEDEC RAM vendor decoding**: `wellhw` resolves raw JEDEC JEP106
  manufacturer codes from dmidecode (e.g. `8313` → `Golden Empire`).
  The ID table ships as `/usr/share/wellutils/jedec.sh`.
- **No root needed**: everything is read from sysfs/`/proc`; dmidecode and
  decode-dimms are used with passwordless sudo when available (optional).
- **S.M.A.R.T. health in `wellblock`**: the per-disk detail view checks
  the overall health and flags failing critical attributes (reallocated
  sectors, pending/uncorrectable errors, CRC errors) in colour.

## Dependencies

Required: `bash`, `python`, `coreutils`, `procps-ng`, `hwdata`.

Optional: `pciutils`, `usbutils`, `smartmontools` (wellsensors and
wellblock S.M.A.R.T.), `nvme-cli`, `dmidecode`, `i2c-tools`
(decode-dimms fallback for RAM detail), `util-linux` (lscpu for
wellcpu).

## License

MIT, except the JEDEC JEP106 vendor table (`jedec.sh`) which is extracted
from i2c-tools `decode-dimms` (GPL-2.0, (c) the i2c-tools authors); see
`LICENSE` for full attribution.
