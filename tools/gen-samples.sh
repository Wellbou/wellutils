#!/usr/bin/env bash
# gen-samples.sh -- regenerate SAMPLES.md from live tool output.
# Box mode via a pty (script -qec) so every tool renders its real frame,
# wrapped in GitHub-flavored ```ansi fences. OSC sequences (terminal
# session fingerprints: machine-id, boot-id, cwd) are stripped.
# Run from the repo root:  tools/gen-samples.sh
set -euo pipefail
cd "$(dirname "$0")/.."

strip_noise() {
    tr -d '\r' | sed 's/\x1b\][^\x07\x1b]*\(\x07\|\x1b\\\)//g'
}

gen() {  # gen <title> <command-line-for-$-line> <command-to-run>
    printf '\n## %s\n\n```sh\n$ %s\n```\n\n```ansi\n' "$1" "$2"
    script -qec "$3" /dev/null | strip_noise
    echo '```'
}

{
echo "# Live output samples / Живые примеры вывода"
echo
echo "Реальный вывод с машины автора (Arch Linux, Xeon E3-1230 V2,"
echo "GTX 1050 Ti, два монитора 20\" 1600x900). Блоки ниже - ANSI:"
echo "GitHub красит их прямо в браузере, в терминале выглядит так же."
echo
echo "Real output from the author's machine. The blocks below are ANSI -"
echo "GitHub renders the colors inline."
gen "wellcpu" "wellcpu" "sudo -n wellcpu"
gen "wellmem" "wellmem" "wellmem"
gen "wellgpu" "wellgpu" "wellgpu"
gen "wellsensors" "wellsensors" "sudo -n wellsensors"
gen "wellhw" "wellhw" "sudo -n wellhw"
gen "wellusb" "wellusb" "wellusb"
gen "wellpci" "wellpci" "wellpci"
gen "wellblock" "wellblock" "wellblock"
gen "wellper" "wellper" "wellper"
gen "wellnet" "wellnet" "wellnet"
gen "wellpower" "wellpower" "wellpower"
gen "welldoctor" "welldoctor" "sudo -n welldoctor"
gen "wellup" "wellup --check" "wellup --check"
gen "wellfetch" "wellfetch" "wellfetch"
gen "статус-бары (status bars)" \
    "wellcpu --short && wmem --short && wsensors --short && wgpu --short && wnet --short && wdoc --short" \
    "for c in 'wellcpu --short' 'wmem --short' 'wsensors --short' 'wgpu --short' 'wnet --short' 'wdoc --short'; do script -qec \"\$c\" /dev/null | tr -d '\r'; done"
} > SAMPLES.md

echo "SAMPLES.md regenerated ($(wc -l < SAMPLES.md) lines, OSC stripped)"
