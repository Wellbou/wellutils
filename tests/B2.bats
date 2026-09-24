#!/usr/bin/env bats
# wellusb / wellpci / wellmod regression tests (group B2)

setup() {
    cd "$BATS_TEST_DIRNAME/.."
    if command -v python3 >/dev/null 2>&1; then PY=python3; else PY=python; fi
    U="$BATS_TEST_TMPDIR/usb"
    mkdir -p "$U"
    # fake USB tree: 2 root hubs with identical VID:PID, 2 identical mice
    mkusb() {   # name bus dev vid pid class speed product
        local d="$U/$1"; mkdir -p "$d"
        echo "$2" > "$d/busnum"; echo "$3" > "$d/devnum"; echo "$4" > "$d/idVendor"
        echo "$5" > "$d/idProduct"; echo "$6" > "$d/bDeviceClass"; echo "$7" > "$d/speed"
        [ -n "$8" ] && echo "$8" > "$d/product"
        echo " 2.00" > "$d/version"
    }
    mkif() {    # dev iface class subclass driver
        local d="$U/$1/$2"; mkdir -p "$d"
        echo "$3" > "$d/bInterfaceClass"; echo "$4" > "$d/bInterfaceSubClass"
        printf 'DEVTYPE=usb_interface\nDRIVER=%s\n' "$5" > "$d/uevent"
    }
    mkusb usb1 1 1 1d6b 0002 09 480 "EHCI Host Controller"
    mkusb usb2 2 1 1d6b 0002 09 480 "EHCI Host Controller"
    mkif usb1 1-0:1.0 09 00 hub; mkif usb2 2-0:1.0 09 00 hub
    mkusb 2-1 2 2 046d c077 00 1.5 "USB Optical Mouse"
    mkusb 2-2 2 3 046d c077 00 1.5 "USB Optical Mouse"
    mkif 2-1 2-1:1.0 03 01 usbhid; mkif 2-2 2-2:1.0 03 01 usbhid
    mkusb 2-10 2 4 2341 0043 02 12 ""
    mkif 2-10 2-10:1.0 02 02 cdc_acm
}

@test "wellusb: native sysfs scan, per-device classes, JSON valid" {
    run env WELLUSB_SYSFS_ROOT="$U" ./src/wellusb --json -l en
    [ "$status" -eq 0 ]
    echo "$output" | "$PY" -c '
import json, sys
d = json.load(sys.stdin)
assert d["summary"] == {"devices": 5, "hubs": 2}, d["summary"]
devs = d["devices"]
assert [x["bus"] for x in devs] == ["01", "02", "02", "02", "02"], devs
assert devs[0]["type_key"] == "hub" and devs[1]["type_key"] == "hub"
assert devs[2]["type_key"] == "mouse" and devs[3]["type_key"] == "mouse"
assert devs[2]["path"] == "2-1" and devs[3]["path"] == "2-2"
assert devs[4]["path"] == "2-10" and devs[4]["type_key"] == "serial", devs[4]
assert devs[4]["driver"] == "cdc_acm"
'
}

@test "wellusb: Type line shown even when a serial exists" {
    echo SER123 > "$U/2-1/serial"
    run env WELLUSB_SYSFS_ROOT="$U" COLUMNS=80 ./src/wellusb --box --color never --no-emoji -l en
    [ "$status" -eq 0 ]
    [[ "$output" == *"Serial:  SER123"* ]]
    [ "$(grep -c 'Type:' <<< "$output")" -eq 5 ]
}

@test "wellusb: missing /sys/bus/usb -> graceful message, empty JSON" {
    run env WELLUSB_SYSFS_ROOT=/nonexistent ./src/wellusb --plain -l en
    [ "$status" -eq 0 ]
    [[ "$output" == *"/sys/bus/usb"* || "$output" == *usb_no_sysfs* ]]   # key until lang merge
    run env WELLUSB_SYSFS_ROOT=/nonexistent ./src/wellusb --json
    [ "$status" -eq 0 ]
    echo "$output" | "$PY" -c 'import json,sys; d=json.load(sys.stdin); assert d["devices"] == [] and d["sysfs"] is False'
}

@test "wellpci: works without lspci, skips Unknown/x0 link badge" {
    P="$BATS_TEST_TMPDIR/pci"; mkdir -p "$P/0000:02:00.0" "$P/0000:00:00.0"
    printf '0x030000\n' > "$P/0000:02:00.0/class"; printf '0x10de\n' > "$P/0000:02:00.0/vendor"
    printf '0x1c82\n' > "$P/0000:02:00.0/device"; printf 'Unknown\n' > "$P/0000:02:00.0/current_link_speed"
    printf '0\n' > "$P/0000:02:00.0/current_link_width"
    printf '0x060000\n' > "$P/0000:00:00.0/class"; printf '0x8086\n' > "$P/0000:00:00.0/vendor"
    printf '0x0158\n' > "$P/0000:00:00.0/device"
    bin="$BATS_TEST_TMPDIR/bin"; mkdir -p "$bin"
    for c in bash awk date dirname readlink tr sed head cat grep stty tput; do command -v $c >/dev/null || continue; ln -sf "$(command -v $c)" "$bin/$c"; done
    run env -i PATH="$bin" HOME=/tmp WELLPCI_SYSFS_ROOT="$P" bash ./src/wellpci --plain -l en --color never
    [ "$status" -eq 0 ]
    [[ "$output" != *Unknown* ]]
    [[ "$output" == *"0000:02:00.0"* ]]
    [[ "$output" != *"0000:00:00.0"* ]]
    [[ "$output" == *"2 "* ]]
    run env -i PATH="$bin" HOME=/tmp WELLPCI_SYSFS_ROOT="$P" bash ./src/wellpci --json
    echo "$output" | "$PY" -c '
import json, sys
d = json.load(sys.stdin)
assert d["summary"]["devices"] == 1 and d["summary"]["total"] == 2, d["summary"]
assert d["devices"][0]["link_speed"] == "" and d["devices"][0]["description"] != ""
'
}

@test "wellmod: --deps honors --json and normalizes dashes" {
    dep="$BATS_TEST_TMPDIR/modules.dep"
    printf '%s\n' 'kernel/sound/snd-hda-intel.ko.zst: kernel/sound/snd-hda-codec.ko.zst kernel/sound/snd.ko.zst' \
        'kernel/net/veth.ko.zst:' > "$dep"
    run env WELLMOD_DEPFILE="$dep" ./src/wellmod --deps snd-hda-intel --json
    [ "$status" -eq 0 ]
    echo "$output" | "$PY" -c '
import json, sys
d = json.load(sys.stdin)
assert d["found"] and d["module"] == "snd_hda_intel"
assert [x["name"] for x in d["depends"]] == ["snd_hda_codec", "snd"]
'
    run env WELLMOD_DEPFILE="$dep" ./src/wellmod --deps snd_hda_intel --plain -l en
    [ "$status" -eq 0 ]
    [[ "$output" == *snd_hda_codec* ]]
    run env WELLMOD_DEPFILE="$dep" ./src/wellmod --deps veth --plain -l en
    [[ "$output" == *"No dependencies"* ]]
}

@test "wellmod: integer fmt_size and category icons" {
    pm="$BATS_TEST_TMPDIR/modules"
    printf '%s\n' 'mac80211 1782000 4 - Live 0x0' 'snd 159744 10 - Live 0x0' 'veth 1000 0 - Live 0x0' > "$pm"
    run env WELLMOD_PROC_MODULES="$pm" ./src/wellmod --box --color never --emoji -l en
    [ "$status" -eq 0 ]
    [[ "$output" == *"📡 mac80211"*"1.7 MB"* ]]
    [[ "$output" == *"156.0 KB"* ]]
    [[ "$output" == *"1000 B"* ]]
    run env WELLMOD_PROC_MODULES="$pm" ./src/wellmod --json
    echo "$output" | "$PY" -c 'import json,sys; d=json.load(sys.stdin); assert d["summary"]["count"] == 3 and d["modules"][0]["category"] == "wifi"'
}
