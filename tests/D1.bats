# Installer / launcher / self-update regressions (group D1).
# Part of wellutils by wellbou_

setup() {
    T="$(mktemp -d "${BATS_TMPDIR:-/tmp}/wu-d1.XXXXXX")"
    P="$T/pfx"
}
teardown() { rm -rf -- "$T"; }

inst() { WELLUTILS_LOCAL=1 ./install.sh --prefix="$P" --no-deps "$@" </dev/null; }

@test "install: every lib (incl. parse.sh) lands and tools run from the prefix" {
    run inst
    [ "$status" -eq 0 ]
    for f in bootstrap.sh lang.sh box.sh cli.sh parse.sh jedec.sh distro_art.sh VERSION; do
        [ -f "$P/share/wellutils/$f" ]
    done
    [ -x "$P/bin/whtml" ] && [ -L "$P/bin/well" ] && [ -L "$P/bin/wutils" ]
    [ -f "$P/share/zsh/site-functions/_wellmem" ]
    [ -f "$P/share/fish/vendor_completions.d/wellmem.fish" ]
    run "$P/bin/wellmem" --plain -l en
    [ "$status" -eq 0 ]
    run "$P/bin/well" --json mem
    [ "$status" -eq 0 ]
    printf '%s' "$output" | python3 -m json.tool >/dev/null
}

@test "uninstall removes everything listed in the manifest" {
    inst >/dev/null
    run inst --uninstall
    [ "$status" -eq 0 ]
    [ ! -e "$P" ]
}

@test "launcher: --version reads VERSION, unknown command exits 2" {
    run ./src/wellutils --version
    [ "$output" = "wellutils $(cat src/VERSION)" ]
    run ./src/wellutils nosuchcmd
    [ "$status" -eq 2 ]
}

@test "self-update: installs a newer local tree into the detected prefix" {
    inst >/dev/null
    mkdir -p "$T/new" && cp -r install.sh src "$T/new/"
    echo 99.0.0-1 > "$T/new/src/VERSION"
    run env WELLUTILS_SELF_SRC="$T/new" "$P/bin/wellup" --self-update --json
    [[ "$output" == *'"status": "update-available"'* ]]
    run env WELLUTILS_SELF_SRC="$T/new" "$P/bin/wellup" --self-update --yes --color never
    [ "$status" -eq 0 ]
    [ "$(cat "$P/share/wellutils/VERSION")" = "99.0.0-1" ]
}

@test "self-update from a checkout is refused politely" {
    run ./src/wellup --self-update
    [ "$status" -eq 0 ]
}
