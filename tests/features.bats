# Short-mode and new-tool smoke tests.
# Part of wellutils by wellbou_

@test "wellcpu --short is a percentage or dash" {
    run ./wellcpu --short
    [ "$status" -eq 0 ]
    [[ "$output" =~ ^[0-9]+%$ ]] || [[ "$output" == "-" ]]
}

@test "wellmem --short matches N/N format" {
    run ./wellmem --short
    [ "$status" -eq 0 ]
    [[ "$output" =~ ^[0-9.]+/[0-9.]+GiB$|^-$ ]]
}

@test "wellsensors --short is a temperature or dash" {
    run ./wellsensors --short
    [ "$status" -eq 0 ]
    [[ "$output" =~ ^[0-9]+°C$|^-$ ]]
}

@test "wellnet --json has connection object" {
    if command -v python3 >/dev/null 2>&1; then PY=python3; else PY=python; fi
    run bash -c "./wellnet --json 2>/dev/null | $PY -c \"import json,sys; d=json.load(sys.stdin); assert 'connection' in d\""
    [ "$status" -eq 0 ]
}

@test "welldoctor exit code is 0/1/2" {
    run ./welldoctor --plain
    [[ "$status" -le 2 && "$status" -ge 0 ]]
}

@test "wellhw snapshot+diff roundtrip reports no changes" {
    local f="$(mktemp)"
    ./wellhw --snapshot "$f"
    run ./wellhw --diff "$f"
    if [ "$status" -ne 0 ]; then
        echo "diff said: $output"
        false
    fi
    rm -f "$f"
}

@test "wellup --pacnew lists leftovers or none" {
    run ./wellup --pacnew --plain
    [ "$status" -eq 0 ]
}

@test "whtml: default run is fully offline (no curl) and emits HTML" {
    local rundir="$(mktemp -d)"
    printf '#!/bin/sh\nexit 127\n' > "$rundir/curl"; chmod +x "$rundir/curl"
    # Hide curl; whtml must not need it (no network by default).
    run env PATH="$rundir:/usr/bin:/bin" ./whtml --no-open --output "$rundir/report.html"
    [ "$status" -eq 0 ]
    [ -s "$rundir/report.html" ]
    head -1 "$rundir/report.html" | grep -q "<!DOCTYPE html>"
    # No external resources / URLs.
    if grep -q 'https://' "$rundir/report.html"; then
        echo "report references an external resource"
        false
    fi
}

@test "whtml: report contains SMART" {
    local f="$(mktemp)"
    run ./whtml --no-open --output "$f"
    [ "$status" -eq 0 ]
    grep -qi "S.M.A.R.T." "$f"
}

@test "whtml: --ai without an endpoint stays offline and succeeds" {
    local f="$(mktemp)"
    unset WHTML_AI_ENDPOINT
    run ./whtml --ai --no-open --output "$f"
    [ "$status" -eq 0 ]
    [ -s "$f" ]
}

@test "whtml: default CLI contains cyrillic" {
    local f="$(mktemp)"
    run ./whtml --no-open --output "$f"
    [ "$status" -eq 0 ]
    grep -qP '[А-Яа-я]' "$f"
}

@test "whtml: --ami is English only (no cyrillic)" {
    local f="$(mktemp)"
    run ./whtml --ami --no-open --output "$f"
    [ "$status" -eq 0 ]
    ! grep -qP '[А-Яа-я]' "$f"
}

@test "whtml: --ami has AMIBIOS banner and embedded font" {
    local f="$(mktemp)"
    run ./whtml --ami --no-open --output "$f"
    [ "$status" -eq 0 ]
    grep -q "AMIBIOS SETUP UTILITY" "$f"
    grep -q "data:font" "$f"
}

@test "whtml: --ami uses English units (GB, GHz, MHz)" {
    local f="$(mktemp)"
    run ./whtml --ami --no-open --output "$f"
    [ "$status" -eq 0 ]
    grep -q " GB" "$f"
    grep -q " GHz" "$f"
    grep -q " MHz" "$f"
    ! grep -q " ГБ" "$f"
    ! grep -q " ГГц" "$f"
    ! grep -q " МГц" "$f"
}

@test "whtml: --ami contains exact disk models" {
    local f="$(mktemp)"
    run ./whtml --ami --no-open --output "$f"
    [ "$status" -eq 0 ]
    grep -q "WDC" "$f"
}

@test "whtml: --ami has no https://" {
    local f="$(mktemp)"
    run ./whtml --ami --no-open --output "$f"
    [ "$status" -eq 0 ]
    ! grep -q "https://" "$f"
}

@test "whtml: --help shows --ami" {
    run ./whtml --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"--ami"* ]]
}
