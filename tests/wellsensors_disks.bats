# wellsensors must show spun-down (STANDBY) disks instead of silently
# dropping them: smartctl -n standby exits 2 without waking the disk.
# Part of wellutils by wellbou_

setup() {
    FAKEBIN="$BATS_TEST_TMPDIR/bin"; mkdir -p "$FAKEBIN"
    cat > "$FAKEBIN/smartctl" <<'STUB'
#!/usr/bin/env bash
dev="${@: -1}"
if [[ "$*" == *" -A "* ]]; then
    if [[ "$dev" == /dev/sdz ]]; then
        echo "Device is in STANDBY mode, exit(2)" >&2
        exit 2
    fi
    printf '%s\n' \
        'ID# ATTRIBUTE_NAME          FLAG     VALUE WORST THRESH TYPE      UPDATED  WHEN_FAILED RAW_VALUE' \
        '194 Temperature_Celsius     0x0022   100   100   000    Old_age   Always       -       42'
    exit 0
fi
if [[ "$*" == *" -i "* ]]; then
    echo "Device Model: FAKE-DISK-${dev##*/}"
    exit 0
fi
exit 0
STUB
    chmod +x "$FAKEBIN/smartctl"
    # Route wu_root_run through the stub even when real sudo exists.
    cat > "$FAKEBIN/sudo" <<'STUB'
#!/usr/bin/env bash
while [[ "${1:-}" == -* ]]; do shift; done
exec "$@"
STUB
    chmod +x "$FAKEBIN/sudo"
}

@test "wellsensors: spun-down disk shown as standby, not dropped (en)" {
    run env PATH="$FAKEBIN:$PATH" WELLSENSORS_DISKS="/dev/sdz /dev/sdy" ./src/wellsensors --plain --color never --lang en
    [ "$status" -eq 0 ]
    [[ "$output" == *"standby (spun down)"* ]]
    [[ "$output" == *"42°C"* ]]
}

@test "wellsensors: spun-down disk shown as standby, not dropped (ru)" {
    run env PATH="$FAKEBIN:$PATH" WELLSENSORS_DISKS="/dev/sdz /dev/sdy" ./src/wellsensors --plain --color never --lang ru
    [ "$status" -eq 0 ]
    [[ "$output" == *"ожидание (диск остановлен)"* ]]
}

@test "wellsensors: standby disk has null temp_c and state in --json" {
    if command -v python3 >/dev/null 2>&1; then PY=python3; else PY=python; fi
    run env PATH="$FAKEBIN:$PATH" WELLSENSORS_DISKS="/dev/sdz /dev/sdy" ./src/wellsensors --json --lang en
    [ "$status" -eq 0 ]
    echo "$output" | "$PY" -c "
import json,sys
ds={d['device']: d for d in json.load(sys.stdin)['disks']}
assert ds['/dev/sdz']['temp_c'] is None, ds
assert ds['/dev/sdz']['state'] == 'standby', ds
assert ds['/dev/sdy']['temp_c'] == 42, ds
assert ds['/dev/sdy']['state'] == 'ok', ds
"
}
