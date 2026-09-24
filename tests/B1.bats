#!/usr/bin/env bats
# wellhw / wellblock regression tests (group B1)

setup() {
    cd "$BATS_TEST_DIRNAME/.."
    DMI="$BATS_TEST_TMPDIR/dmi.txt"
    printf '%s\n' \
        '# dmidecode 3.5' \
        'Handle 0x0011, DMI type 17, 40 bytes' \
        'Memory Device' \
        $'\tSize: 8192 MB' \
        $'\tForm Factor: SODIMM' \
        $'\tLocator: ChannelA-DIMM0' \
        $'\tType: DDR4' \
        $'\tSpeed: 2667 MT/s' \
        $'\tManufacturer: 80AD000080AD' \
        $'\tSerial Number: 00000000' \
        $'\tPart Number: HMA81GS6AFR8N-UH    ' \
        $'\tConfigured Memory Speed: 2400 MT/s' \
        '' \
        'Handle 0x0012, DMI type 17, 40 bytes' \
        'Memory Device' \
        $'\tSize: No Module Installed' \
        $'\tLocator: ChannelB-DIMM0' \
        $'\tManufacturer: Not Specified' \
        '' \
        'Handle 0x0013, DMI type 17, 40 bytes' \
        'Memory Device' \
        $'\tSize: 0 MB' \
        $'\tLocator: DIMM 3' \
        $'\tPart Number: Unknown' \
        '' \
        'Handle 0x0014, DMI type 17, 92 bytes' \
        'Memory Device' \
        $'\tVolatile Size: 16 GB' \
        $'\tSize: 16 GB' \
        $'\tLocator: DIMM_B1' \
        $'\tType: DDR5' \
        $'\tSpeed: 4800 MT/s' \
        $'\tManufacturer: Bank 5, Hex 0xCD' \
        $'\tPart Number: Unknown' \
        $'\tNon-Volatile Size: None' \
        $'\tCache Size: None' \
        $'\tLogical Size: None' > "$DMI"
}

@test "wellhw: dmidecode parser ignores Non-Volatile/Cache/Logical Size and empty slots" {
    run env WELLHW_DMI_FILE="$DMI" ./src/wellhw --json
    [ "$status" -eq 0 ]
    echo "$output" | python3 -c '
import json,sys
m=json.load(sys.stdin)["memory"]
assert m["modules"]==2, m
assert m["size_mb"]==8192+16384, m
s=m["slots"]
assert s[0]["manufacturer"].startswith("SK Hynix"), s[0]
assert s[1]["manufacturer"]=="G Skill Intl", s[1]
assert s[1]["part_number"]=="", s[1]
assert s[0]["serial"]=="", s[0]
'
}

@test "wellhw: no placeholder PN in text output" {
    run env WELLHW_DMI_FILE="$DMI" ./src/wellhw --plain --color never -l en
    [ "$status" -eq 0 ]
    [[ "$output" != *"PN: Unknown"* ]]
    [[ "$output" != *"Not Specified"* ]]
    [[ "$output" == *"G Skill Intl"* ]]
}

@test "wellhw: JEDEC normalisation of manufacturer ids" {
    run bash -c '
        source src/parse.sh; source src/jedec.sh
        eval "$(sed -n "/^_hw_clean()/,/^}/p;/^_hw_norm_manuf()/,/^}/p" src/wellhw)"
        for m in 80CE 80AD000080AD 0x80CE 0198 859B 04CB 802C 8313 "Bank 5, Hex 0xCD" 0000 FFFF; do
            _hw_norm_manuf "$m" o; printf "%s=%s\n" "$m" "$o"
        done'
    [ "$status" -eq 0 ]
    [[ "$output" == *"80CE=Samsung"* ]]
    [[ "$output" == *"80AD000080AD=SK Hynix"* ]]
    [[ "$output" == *"0x80CE=Samsung"* ]]
    [[ "$output" == *"0198=Kingston"* ]]
    [[ "$output" == *"859B=Crucial"* ]]
    [[ "$output" == *"04CB=A-DATA"* ]]
    [[ "$output" == *"802C=Micron"* ]]
    [[ "$output" == *"8313=Golden Empire"* ]]
    [[ "$output" == *"Bank 5, Hex 0xCD=G Skill"* ]]
    [[ "$output" == *$'0000=\n'* ]]
    [[ "$output" == *"FFFF=" ]]
}

@test "wellblock: JSON booleans are true/false/null" {
    run ./src/wellblock --json
    [ "$status" -eq 0 ]
    echo "$output" | python3 -c '
import json,sys
d=json.load(sys.stdin)
for x in d["disks"]:
    assert x["rotational"] in (True,False,None), x
    assert x["removable"] in (True,False), x
'
}

@test "wellblock: unknown disk name exits 3" {
    run ./src/wellblock sdzz9
    [ "$status" -eq 3 ]
}

@test "wellblock: any /sys/block entry is accepted with or without /dev/" {
    local b
    for b in /sys/block/*; do b=${b##*/}; break; done
    [ -n "$b" ] || skip "no block devices"
    run ./src/wellblock "/dev/$b" --json
    [ "$status" -eq 0 ]
    echo "$output" | python3 -c 'import json,sys; json.load(sys.stdin)'
    run ./src/wellblock "$b" --plain --color never
    [ "$status" -eq 0 ]
}
