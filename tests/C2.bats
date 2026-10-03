# wellnet / wellper regressions (group C2)
setup() {
    if command -v python3 >/dev/null 2>&1; then PY=python3; else PY=python; fi
    FAKE="$BATS_TEST_TMPDIR/bin"; mkdir -p "$FAKE"
    # hermetic: display-state tracking must never read/write the real home
    export XDG_STATE_HOME="$BATS_TEST_TMPDIR/state"
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

@test "wellper: xrandr is invoked with --current (no hardware polling)" {
    cat > "$FAKE/xrandr" <<'EOF'
#!/bin/bash
printf '%s\n' "$*" >> "${XRANDR_LOG:?}"
printf 'DVI-D-0 connected primary 1600x900+0+0 (normal left inverted right x axis y axis) 443mm x 249mm\n'
printf '\tEDID:\n'
printf '\t\t00ffffffffffff005a63266c010101010101010101010101\n'
printf '   1600x900      60.00*+\n'
printf 'HDMI-0 connected 1600x900+1600+0 (normal left inverted right x axis y axis) 443mm x 249mm\n'
printf '   1600x900      60.00*+\n'
EOF
    chmod +x "$FAKE/xrandr"
    local log="$BATS_TEST_TMPDIR/xrandr.log"
    run env PATH="$FAKE:$PATH" DISPLAY=:0 XRANDR_LOG="$log" ./src/wellper --plain -l en
    [ "$status" -eq 0 ]
    grep -q -- '--current' "$log"
    grep -q -- '--props' "$log"
    [[ "$output" == *"DVI-D-0"* ]]
    [[ "$output" == *"HDMI-0"* ]]
}

@test "wellper: connected output without an active mode is listed, not dropped" {
    cat > "$FAKE/xrandr" <<'EOF'
#!/bin/bash
printf '%s\n' "$*" >> "${XRANDR_LOG:?}"
printf 'HDMI-0 connected (normal left inverted right x axis y axis)\n'
EOF
    chmod +x "$FAKE/xrandr"
    local log="$BATS_TEST_TMPDIR/xrandr.log"
    run env PATH="$FAKE:$PATH" DISPLAY=:0 XRANDR_LOG="$log" ./src/wellper --plain -l en
    [ "$status" -eq 0 ]
    [[ "$output" == *"HDMI-0"* ]]
    [[ "$output" == *"no active mode"* ]]
}

@test "wellper: a monitor absent vs the previous run is reported as a change" {
    cat > "$FAKE/xrandr" <<'EOF'
#!/bin/bash
printf '%s\n' "$*" >> "${XRANDR_LOG:?}"
printf 'DVI-D-0 connected primary 1600x900+0+0 (normal left inverted right x axis y axis) 443mm x 249mm\n'
printf '   1600x900      60.00*+\n'
printf 'HDMI-0 connected 1600x900+1600+0 (normal left inverted right x axis y axis) 443mm x 249mm\n'
printf '   1600x900      60.00*+\n'
EOF
    chmod +x "$FAKE/xrandr"
    local log="$BATS_TEST_TMPDIR/xrandr.log"
    run env PATH="$FAKE:$PATH" DISPLAY=:0 XRANDR_LOG="$log" ./src/wellper --plain -l en
    [ "$status" -eq 0 ]
    # first run: no baseline yet, no change block
    [[ "$output" != *"Changes since last run"* ]]
    [ -f "$XDG_STATE_HOME/wellutils/wellper.displays" ]
    cp "$XDG_STATE_HOME/wellutils/wellper.displays" "$BATS_TEST_TMPDIR/state.bak"

    # the second monitor disappears before the next run
    cat > "$FAKE/xrandr" <<'EOF'
#!/bin/bash
printf '%s\n' "$*" >> "${XRANDR_LOG:?}"
printf 'DVI-D-0 connected primary 1600x900+0+0 (normal left inverted right x axis y axis) 443mm x 249mm\n'
printf '   1600x900      60.00*+\n'
EOF
    run env PATH="$FAKE:$PATH" DISPLAY=:0 XRANDR_LOG="$log" ./src/wellper --plain -l en
    [ "$status" -eq 0 ]
    [[ "$output" == *"Changes since last run"* ]]
    [[ "$output" == *"missing"* ]]
    [[ "$output" == *"HDMI-0"* ]]
    [[ "$output" == *"Displays: 1/2"* ]]

    # JSON carries the same information (restore the 2-monitor baseline
    # first: the plain run above already saved its own snapshot)
    cp "$BATS_TEST_TMPDIR/state.bak" "$XDG_STATE_HOME/wellutils/wellper.displays"
    env PATH="$FAKE:$PATH" DISPLAY=:0 XRANDR_LOG="$log" ./src/wellper --json -l en \
        | "$PY" -c "import json,sys; d=json.load(sys.stdin); a=d['display_changes']['absent']; assert len(a)==1 and a[0]['name']=='HDMI-0', d['display_changes']"
}
