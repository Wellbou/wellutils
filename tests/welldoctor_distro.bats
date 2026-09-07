# Distro-aware packaging checks: the family is picked from /etc/os-release
# (overridable via _WU_OS_RELEASE) and each distro's own leftover/orphan
# conventions are applied instead of hardcoded Arch rules.
# Part of wellutils by wellbou_

setup() {
    FAKE_OS="$(mktemp)"
    export _WU_OS_RELEASE="$FAKE_OS"
}

teardown() {
    rm -f "$FAKE_OS"
    unset _WU_OS_RELEASE
}

fake_os() { printf 'PRETTY_NAME="Test"\n%s\n' "$1" > "$FAKE_OS"; }

@test "Arch family: pacnew/pacsave label and pacman orphan query" {
    fake_os 'ID=arch'
    run env -u HOME ./welldoctor --plain
    [[ "$output" == *"pacnew/pacsave"* || "$output" == *"Остатки конфигов"* ]]
    [[ "$output" != *"родной менеджер пакетов не определён"* ]]
}

@test "Debian family: dpkg-* label, orphan check attempted" {
    fake_os 'ID=debian'
    run env -u HOME ./welldoctor --plain
    [[ "$output" == *"dpkg-"* ]]
    # apt-get is absent in this test env; the orphan probe must not crash
    [ "$status" -ge 0 ] && [ "$status" -le 2 ]
}

@test "Ubuntu via ID_LIKE hits deb family" {
    fake_os 'ID=someos
ID_LIKE="debian ubuntu"'
    run env -u HOME ./welldoctor --plain
    [[ "$output" == *"dpkg-"* ]]
}

@test "Fedora family: rpmnew/rpmsave label" {
    fake_os 'ID=fedora'
    run env -u HOME ./welldoctor --plain
    [[ "$output" == *"rpmnew/rpmsave"* ]]
}

@test "Alpine family: apk-new label, orphan unsupported" {
    fake_os 'ID=alpine'
    run env -u HOME ./welldoctor --plain
    [[ "$output" == *"apk-new"* ]]
    [[ "$output" == *"orphan check unsupported"* || "$output" == *"не поддерживается"* ]]
}

@test "Gentoo family: _cfg* label, orphan unsupported" {
    fake_os 'ID=gentoo'
    run env -u HOME ./welldoctor --plain
    [[ "$output" == *"_cfg*"* || "$output" == *"_cfg"* ]]
    [[ "$output" == *"orphan check unsupported"* || "$output" == *"не поддерживается"* ]]
}

@test "Unknown family: both distro checks gracefully skipped" {
    fake_os 'ID=microcosm'
    run env -u HOME ./welldoctor --plain
    [[ "$output" == *"родной менеджер пакетов не определён"* ]]
    [[ "$output" == *"orphan check unsupported"* || "$output" == *"не поддерживается"* ]]
}

@test "--json emits confleft/orphans checks without crashing on any family" {
    fake_os 'ID=debian'
    run env -u HOME ./welldoctor --json
    [ "$status" -ge 0 ] && [ "$status" -le 2 ]
    [[ "$output" == *'"confleft"'* ]]
    [[ "$output" == *'"orphans"'* ]]
}