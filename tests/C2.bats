# wellnet / wellper regressions (group C2)
setup() {
    if command -v python3 >/dev/null 2>&1; then PY=python3; else PY=python; fi
    FAKE="$BATS_TEST_TMPDIR/bin"; mkdir -p "$FAKE"
}

@test "wellnet: tab-indented iw output + trailing && does not kill the tool" {
    printf '#!/bin/bash\nprintf "Connected to AA:BB:CC:DD:EE:FF (on x)\\n\\tSSID: Net One\\n\\tsignal: -65 dBm\\n\\ttx bitrate: 72.2 MBit/s MCS 7\\n"\n' > "$FAKE/iw"
    chmod +x "$FAKE/iw"
    run env PATH="$FAKE:$PATH" ./src/wellnet --plain -l en --no-emoji
    [ "$status" -eq 0 ]
    [[ "$output" != *"MBit/s Mb/s"* ]]
}

@test "wellnet: gateway only from 'via', busybox-style unfiltered route list" {
    printf '#!/bin/bash\ncase "$*" in\n"route get 1") echo "1.0.0.0 dev ppp0 src 10.1.1.1";;\n"route show"*) printf "default dev ppp0 scope link metric 700\\n10.0.0.0/24 dev eth9 scope link\\n";;\n*) exit 1;;\nesac\n' > "$FAKE/ip"
    chmod +x "$FAKE/ip"
    run env PATH="$FAKE:$PATH" ./src/wellnet --json
    [ "$status" -eq 0 ]
    echo "$output" | "$PY" -c "import json,sys; d=json.load(sys.stdin); assert d['connection']['gateway'] is None, d; assert len(d['default_routes'])==1, d"
}

@test "wellnet: --json valid and --plain works without ip/ss/iw" {
    for c in bash awk sort cut head readlink dirname basename date tr cat uname; do ln -sf "$(command -v $c)" "$FAKE/"; done
    run env PATH="$FAKE" ./src/wellnet --plain
    [ "$status" -eq 0 ]
    env PATH="$FAKE" ./src/wellnet --json | "$PY" -c "import json,sys; json.load(sys.stdin)"
}

@test "wellper: own flags still work through cli.sh" {
    run ./src/wellper --sections usb,audio --groups input --plain
    [ "$status" -eq 0 ]
    run ./src/wellper --sections=bogus
    [ "$status" -eq 2 ]
    run ./src/wellper --terse
    [ "$status" -eq 0 ]
    ./src/wellper --json | "$PY" -c "import json,sys; d=json.load(sys.stdin); assert d['tool']=='wellper' and 'summary' in d"
}
