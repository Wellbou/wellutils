# S.M.A.R.T. severity: a disk can PASS overall while remapped sectors pile
# up, so welldoctor must warn on bad attributes, not only on FAILED.
# Part of wellutils by wellbou_

setup() {
    SYSBLK="$BATS_TEST_TMPDIR/sysblock"; mkdir -p "$SYSBLK/sdz"
    FAKEBIN="$BATS_TEST_TMPDIR/bin"; mkdir -p "$FAKEBIN"
    # Toshiba-like report: overall PASSED, but 184 reallocated sectors,
    # 23 reallocated events and a past-marginal attribute (rc bit 5 set).
    cat > "$FAKEBIN/smartctl" <<'STUB'
#!/usr/bin/env bash
if [[ "$*" == *"-a"* ]]; then
    printf '%s\n' \
        'smartctl 7.5 (local build)' \
        '=== START OF READ SMART DATA SECTION ===' \
        'SMART overall-health self-assessment test result: PASSED' \
        'Please note the following marginal Attributes:' \
        'ID# ATTRIBUTE_NAME          FLAG     VALUE WORST THRESH TYPE      UPDATED  WHEN_FAILED RAW_VALUE' \
        '  5 Reallocated_Sector_Ct   0x0033   099   099   010    Pre-fail  Always       -       184' \
        '196 Reallocated_Event_Count 0x0032   100   100   000    Old_age   Always       -       23' \
        '190 Airflow_Temperature_Cel 0x0022   069   037   040    Old_age   Always   In_the_past 31'
    exit 32
fi
printf 'SMART overall-health self-assessment test result: PASSED\n'
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

@test "sick disk (reallocated sectors, overall PASSED) warns, not ok" {
    run env PATH="$FAKEBIN:$PATH" _WD_SYSBLOCK="$SYSBLK" ./src/welldoctor --plain -l en
    [ "$status" -eq 1 ]
    [[ "$output" == *"sdz"* ]]
    [[ "$output" == *"S.M.A.R.T. warning"* ]]
    [[ "$output" == *"Reallocated_Sector_Ct=184"* ]]
}

@test "sick disk appears as warning in --json" {
    if command -v python3 >/dev/null 2>&1; then PY=python3; else PY=python; fi
    run env PATH="$FAKEBIN:$PATH" _WD_SYSBLOCK="$SYSBLK" ./src/welldoctor --json
    [ "$status" -eq 1 ]
    echo "$output" | "$PY" -c "import json,sys; d=json.load(sys.stdin); ss=[c for c in d['checks'] if c['check']=='smart_sdz']; assert ss and ss[0]['status']=='warning', d['checks']"
}

@test "healthy disk (overall PASSED, clean attributes) stays ok" {
    cat > "$FAKEBIN/smartctl" <<'STUB'
#!/usr/bin/env bash
printf '%s\n' \
    'smartctl 7.5 (local build)' \
    '=== START OF READ SMART DATA SECTION ===' \
    'SMART overall-health self-assessment test result: PASSED' \
    'ID# ATTRIBUTE_NAME          FLAG     VALUE WORST THRESH TYPE      UPDATED  WHEN_FAILED RAW_VALUE' \
    '  5 Reallocated_Sector_Ct   0x0033   100   100   010    Pre-fail  Always       -       0' \
    '197 Current_Pending_Sector  0x0032   100   100   000    Old_age   Always       -       0'
STUB
    chmod +x "$FAKEBIN/smartctl"
    run env PATH="$FAKEBIN:$PATH" _WD_SYSBLOCK="$SYSBLK" \
        _WU_OS_RELEASE=/dev/null _WU_SYSTEMD_RUNDIR="$BATS_TEST_TMPDIR/nonexistent" \
        ./src/welldoctor --plain -l en
    [[ "$output" == *"S.M.A.R.T. healthy"* ]]
    [[ "$output" != *"sdz"* ]]
}

@test "failed disk (overall FAILED) is critical" {
    cat > "$FAKEBIN/smartctl" <<'STUB'
#!/usr/bin/env bash
printf 'SMART overall-health self-assessment test result: FAILED\n'
exit 8
STUB
    chmod +x "$FAKEBIN/smartctl"
    run env PATH="$FAKEBIN:$PATH" _WD_SYSBLOCK="$SYSBLK" ./src/welldoctor --plain -l en
    [ "$status" -eq 2 ]
    [[ "$output" == *"S.M.A.R.T. FAILED"* ]]
    [[ "$output" == *"sdz"* ]]
}
