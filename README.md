# wellutils

A suite of colourful system and peripheral reporting tools for Arch Linux.

## Tools

| Tool          | Purpose                                                    |
|---------------|------------------------------------------------------------|
| `wellper`     | Peripheral report: USB devices, displays, audio            |
| `wellhw`      | Hardware report: CPU, GPU, board, RAM (JEDEC-decoded), ... |
| `wellmem`     | Memory overview from `/proc/meminfo`                       |
| `wellusb`     | USB device listing with hwdata IDS lookup                  |
| `wellpci`     | PCI device listing with class descriptions                 |
| `wellblock`   | Block devices, partitions, mount points                    |
| `wellmod`     | Loaded kernel modules                                      |
| `wellsensors` | Temperatures and fans (hwmon / lm_sensors / nvidia-smi)    |
| `wellfetch`   | System fetch (ASCII/PNG logo, distro info)                 |
| `wellutils`   | Launcher: `wellutils hw`, `wellutils mem`, ...             |

Short aliases are accepted by the launcher: `wusb`, `wpci`, `wblock`,
`wmem`/`wram`/`wellram`, `wmod`, `wsensors`/`wtemp`, `whw`, `wper`,
`wfetch` (e.g. `wellutils wram --plain`). Note: `wellutils sensors` is
intentionally *not* an alias — it would shadow the `sensors` binary
from lm_sensors.

## Install

AUR: `yay -S wellutils` (once published), or build locally:

```sh
makepkg -si
```

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

## Dependencies

Required: `bash`, `python`, `coreutils`, `procps-ng`, `hwdata`.

Optional: `pciutils`, `usbutils`, `smartmontools`, `nvme-cli`, `dmidecode`,
`i2c-tools` (decode-dimms fallback for RAM detail).

## License

MIT, except the JEDEC JEP106 vendor table (`jedec.sh`) which is extracted
from i2c-tools `decode-dimms` (GPL-2.0, (c) the i2c-tools authors); see
`LICENSE` for full attribution.
