# CLI contract shared by every wellutils tool.
# Part of wellutils by wellbou_

TOOLS=(wellcpu wellmem wellgpu wellmod wellblock wellhw wellusb wellpci wellsensors wellper wellfetch wellup wellnet wellpower welldoctor whtml)

setup() {
    # Arch ships `python`, Debian/Fedora ship `python3`.
    if command -v python3 >/dev/null 2>&1; then PY=python3; else PY=python; fi
}

@test "every tool: --help exits 0" {
    for t in "${TOOLS[@]}"; do
        run "./src/$t" --help
        [ "$status" -eq 0 ]
    done
}

@test "every tool: unknown flag exits 2" {
    for t in "${TOOLS[@]}"; do
        run "./src/$t" --definitely-not-a-flag
        [ "$status" -eq 2 ]
    done
}

@test "every tool: --json emits valid JSON (where supported)" {
    for t in wellcpu wellmem wellgpu wellblock wellhw wellsensors wellfetch wellup wellnet wellpower; do
        if ! ./src/"$t" --json >/dev/null 2>&1; then continue; fi
        # json.tool reads stdin as ASCII on python < 3.7 under C/POSIX
        # locales and chokes on the emoji/frame bytes the tools legitimately
        # emit. Decode stdin as UTF-8 instead (py2: plain stdin has no .buffer).
        "./src/$t" --json 2>/dev/null | "$PY" -c "import json,sys,io; s = sys.stdin if not hasattr(sys.stdin,'buffer') else io.TextIOWrapper(sys.stdin.buffer, encoding='utf-8'); json.load(s)"
    done
}

@test "every tool: --plain exits 0" {
    for t in "${TOOLS[@]}"; do
        if [[ "$t" == "wellup" ]]; then
            run "./src/$t" --check --plain
        elif [[ "$t" == "welldoctor" ]]; then
            # Documented contract: exit reflects findings (0 ok / 1 warn / 2 crit).
            run ./src/welldoctor --plain
            if [ "$status" -gt 2 ]; then
                echo "welldoctor rc=$status (must be 0,1 or 2)"
                false
            fi
            continue
        elif [[ "$t" == "whtml" ]]; then
            # No --plain: emits an offline HTML file to a temp path.
            run ./src/whtml --no-open --output /tmp/contract_whtml.html
        else
            run "./src/$t" --plain
        fi
        if [ "$status" -ne 0 ]; then
            echo "--plain FAILED for $t (rc=$status)"
            echo "$output"
            false
        fi
    done
}

@test "--json and --short are mutually exclusive" {
    run ./src/wellcpu --json --short
    [ "$status" -eq 2 ]
}

@test "--html produces an HTML document" {
    run ./src/wellcpu --html
    [ "$status" -eq 0 ]
    [[ "$output" == *"<!DOCTYPE html>"* ]]
}
