# Regression for review finding F1: "degraded" systemd must NOT be treated
# as unavailable - that is exactly the state of a machine with failed units.
# Part of wellutils by wellbou_

setup() {
    FAKEBIN="$(mktemp -d)"
    cat > "$FAKEBIN/systemctl" <<'STUB'
#!/usr/bin/env bash
case "$1" in
    is-system-running) echo "${FAKE_STATE:-running}" ;;
    list-units) [[ "$FAKE_UNITS" != "" ]] && printf '%s\n' "$FAKE_UNITS" ;;
esac
exit 0
STUB
    chmod +x "$FAKEBIN/systemctl"
    mkdir -p "$FAKEBIN/run/systemd/system"
}

teardown() { rm -rf "$FAKEBIN"; }

@test "degraded systemd lists failed units (F1 regression)" {
    export PATH="$FAKEBIN:$PATH"
    export FAKE_STATE=degraded
    export FAKE_UNITS="nginx.service loaded failed failed nginx - high performance web server"
    run env -u HOME ./welldoctor --plain
    [[ "$output" == *"nginx.service"* ]]
    [[ "$output" != *"unavailable"* ]]
    [[ "$output" != *"недоступен"* ]]
    # rc reflects the worst finding: 1 (warn) or 2 (crit from real hardware)
    [ "$status" -ge 1 ] && [ "$status" -le 2 ]
}

@test "degraded systemd lowers the health score below 100" {
    export PATH="$FAKEBIN:$PATH"
    export FAKE_STATE=degraded
    export FAKE_UNITS="nginx.service loaded failed failed nginx"
    run env -u HOME ./welldoctor --short
    [[ "$output" != *"100/100"* ]]
    [[ "$output" =~ W[0-9]+ ]]
}

@test "offline systemd is reported unavailable, failed units not shown" {
    export PATH="$FAKEBIN:$PATH"
    export FAKE_STATE=offline
    export FAKE_UNITS="nginx.service loaded failed failed nginx"
    run env -u HOME ./welldoctor --plain
    [[ "$output" != *"nginx.service"* ]]
    [[ "$output" == *"unavailable"* || "$output" == *"недоступен"* ]]
}

@test "running systemd with no failed units stays green" {
    export PATH="$FAKEBIN:$PATH"
    export FAKE_STATE=running
    export FAKE_UNITS=""
    run env -u HOME ./welldoctor --plain
    [[ "$output" != *"nginx.service"* ]]
    [[ "$output" != *"Сбойный юнит"* ]]
}
