#!/usr/bin/env bash
# gen-samples.sh -- regenerate SAMPLES.md from live tool output.
# Box mode via a pty (script -qec) so every tool renders its real frame,
# wrapped in plain ```text fences. ALL ANSI is stripped (SGR colors, OSC
# terminal fingerprints, 7-bit save/restore) so the frames keep their box
# glyphs but render cleanly in any Markdown viewer (GitHub does not paint
# ANSI, bare escapes look like noise).
# Run from the repo root:  tools/gen-samples.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# Always sample the repo's own tools, not whatever is installed in PATH.
export PATH="$PWD${PATH:+:$PATH}"

strip_noise() {
    tr -d '\r' | sed \
        's/\x1b\][^\x07\x1b]*\(\x07\|\x1b\\\)//g; s/\x1b\[[?;0-9]*[a-zA-Z]//g; s/\x1b[78]//g; /^\^@$/d'
}

gen() {  # gen <title> <command-line-for-$-line> <command-to-run>
    printf '\n## %s\n\n```sh\n$ %s\n```\n\n```text\n' "$1" "$2"
    # Some tools (welldoctor) exit non-zero by contract; the sample is the
    # output, not the code, so swallow it.
    script -qec "$3" /dev/null | strip_noise || true
    echo '```'
}

{
echo "# Live output samples / Живые примеры вывода"
echo
echo "Реальный вывод с машины автора (Arch Linux, Xeon E3-1230 V2,"
echo "GTX 1050 Ti, два монитора 20\" 1600x900). Цвета сняты, чтобы блоки"
echo "одинаково читались в любом просмотрщике - рамки и выравнивание"
echo "сохранены, как в терминале."
echo
echo "Real output from the author's machine. Colors are stripped so the"
echo "blocks render the same way in every Markdown viewer; the frames and"
echo "alignment are kept exactly as they appear in a terminal."
gen "wellcpu" "wellcpu" "sudo -n ./wellcpu"
gen "wellmem" "wellmem" "wellmem"
gen "wellgpu" "wellgpu" "wellgpu"
gen "wellsensors" "wellsensors" "sudo -n ./wellsensors"
gen "wellhw" "wellhw" "sudo -n ./wellhw"
gen "wellusb" "wellusb" "wellusb"
gen "wellpci" "wellpci" "wellpci"
gen "wellblock" "wellblock" "wellblock"
gen "wellper" "wellper" "wellper"
gen "wellnet" "wellnet" "wellnet"
gen "wellpower" "wellpower" "wellpower"
gen "welldoctor" "welldoctor" "sudo -n ./welldoctor"
gen "wellup" "wellup --check" "wellup --check"
gen "wellfetch" "wellfetch" "wellfetch"
gen "статус-бары (status bars)" \
    "wellcpu --short && wmem --short && wsensors --short && wgpu --short && wnet --short && wdoc --short" \
    "for c in 'wellcpu --short' 'wmem --short' 'wsensors --short' 'wgpu --short' 'wnet --short' 'wdoc --short'; do script -qec \"\$c\" /dev/null; done"
} > SAMPLES.md

echo "SAMPLES.md regenerated ($(wc -l < SAMPLES.md) lines, ANSI stripped)"
