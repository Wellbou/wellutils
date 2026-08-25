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
    run bash -c './wellnet --json 2>/dev/null | python3 -c "import json,sys; d=json.load(sys.stdin); assert \"connection\" in d"'
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
    [ "$status" -eq 0 ]
    rm -f "$f"
}

@test "wellup --pacnew lists leftovers or none" {
    run ./wellup --pacnew --plain
    [ "$status" -eq 0 ]
}
