# Scripting with `--json`

Every wellutils report tool can dump what it knows as a single JSON document
on stdout. The format is the same across the whole suite - write one bit of
logic and it works no matter which tool feeds it.

Think it'll be a pain to use? Not really. Look at `whtml`. It doesn't read
sysfs or `/proc` itself; it just runs the other tools with `--json`, joins
their output, and turns it into one HTML page. Here's whtml's main command:

```sh
$ whtml --output ~/report.html      # runs wellcpu, wellhw, wellmem, ... with --json
```

## The envelope

Each document starts with the same few keys so the caller knows what it's
looking at without guessing:

```json
{ "tool": "wellcpu", "version": "1.4.0", "date": "2026-08-30", ... }
```

Everything else is tool-specific. The exact shape is shown by real examples
from an actual machine in [SAMPLES.md](../SAMPLES.md).

## The quick wins

```sh
# CPU model, one field
wellhw --json | jq -r '.cpu.model'

# Load per core, as a small table
wellcpu --json | jq -r '.load[] | "CPU\(.cpu)\t\(.usage_percent)%\t\(.freq_khz/1000) MHz"'

# Hottest GPU sensor, no jq
wellsensors --json | python3 -c 'import json,sys;d=json.load(sys.stdin);t=[g["temp_c"] for g in (d.get("gpu") or []) if g.get("temp_c")];print(max(t) if t else "-")'

# What kind of uplink am I on right now?
wellnet --json | jq -r '.connection.kind'   # vpn / wifi / usb_tether / ethernet
```

Warnings and errors go to stderr, never to stdout, so the JSON stream is
always clean - you can pipe it straight into a parser without trimming.

## Watchdogs and cron

`welldoctor` already aggregates health for cron, but you can build the same
checks from the raw JSON too:

```sh
# exits non-zero when something critical is found
welldoctor --json | jq -e '.summary.critical == 0' >/dev/null \
  || echo "welldoctor reports trouble"

# hardware inventory diff for config management
wellhw --snapshot /etc/wellutils/hw.json
wellhw --diff /etc/wellutils/hw.json              # what changed since last week
```

## Keeping it ascii-safe

Every tool honours the same flags, so your scripts can look the same in logs,
status bars and plain viewing:

```sh
wellfetch --no-emoji              # logs that don't mangle in plain (tty) terminals
```

See the [main README](../README.md) for the full CLI reference, and
[SAMPLES.md](../SAMPLES.md) for the real output of every tool.
