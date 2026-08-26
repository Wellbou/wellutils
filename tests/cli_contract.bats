# CLI contract shared by every wellutils tool.
# Part of wellutils by wellbou_

TOOLS=(wellcpu wellmem wellgpu wellmod wellblock wellhw wellusb wellpci wellsensors wellper wellfetch wellup wellnet wellpower welldoctor)

setup() {
    # Arch ships `python`, Debian/Fedora ship `python3`.
    if command -v python3 >/dev/null 2>&1; then PY=python3; else PY=python; fi
}

@test "every tool: --help exits 0" {
    for t in "${TOOLS[@]}"; do
        run "./$t" --help
        [ "$status" -eq 0 ]
    done
}

@test "every tool: unknown flag exits 2" {
    for t in "${TOOLS[@]}"; do
        run "./$t" --definitely-not-a-flag
        [ "$status" -eq 2 ]
    done
}

@test "every tool: --json emits valid JSON (where supported)" {
    for t in wellcpu wellmem wellgpu wellblock wellhw wellsensors wellfetch wellup wellnet wellpower; do
        if ! ./"$t" --json >/dev/null 2>&1; then continue; fi
        "./$t" --json 2>/dev/null | "$PY" -m json.tool >/dev/null
    done
}

@test "every tool: --plain exits 0" {
    for t in "${TOOLS[@]}"; do
        if [[ "$t" == "wellup" ]]; then
            run "./$t" --check --plain
        elif [[ "$t" == "welldoctor" ]]; then
            # Documented contract: exit reflects findings (0 ok / 1 warn / 2 crit).
            run ./welldoctor --plain
            if [ "$status" -gt 2 ]; then
                echo "welldoctor rc=$status (must be 0,1 or 2)"
                false
            fi
            continue
        else
            run "./$t" --plain
        fi
        if [ "$status" -ne 0 ]; then
            echo "--plain FAILED for $t (rc=$status)"
            echo "$output"
            false
        fi
    done
}

@test "--json and --short are mutually exclusive" {
    run ./wellcpu --json --short
    [ "$status" -eq 2 ]
}

@test "--html produces an HTML document" {
    run ./wellcpu --html
    [ "$status" -eq 0 ]
    [[ "$output" == *"<!DOCTYPE html>"* ]]
}
