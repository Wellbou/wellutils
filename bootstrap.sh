#!/usr/bin/env bash
# bootstrap.sh -- shared library loader for wellutils tools
# Usage: source bootstrap.sh lang box cli [jedec]
# Sets _WU_BOOT_DIR to the resolved source directory.

_wu_resolve_lib() {
    local name="$1" _dir="$2" _path
    _path="${_dir}/${name}"
    [[ -f "$_path" ]] || _path="$(dirname "$(dirname "$_dir")")/share/wellutils/${name}"
    [[ -f "$_path" ]] || _path="/usr/local/share/wellutils/${name}"
    [[ -f "$_path" ]] || _path="/usr/share/wellutils/${name}"
    [[ -f "$_path" ]] || _path="/etc/wellutils/${name}"
    if [[ -f "$_path" ]]; then
        source "$_path"
    else
        printf 'wellutils: cannot find %s\n' "$name" >&2
        return 1
    fi
}

# Associative arrays and ${var,,} require bash 4 (macOS ships 3.2).
if (( BASH_VERSINFO[0] < 4 )); then
    printf 'wellutils: bash >= 4.0 required, found %s. On macOS: brew install bash\n' "$BASH_VERSION" >&2
    return 1 2>/dev/null || exit 1
fi

_WU_BOOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
for _wu_lib_name in "$@"; do
    if ! _wu_resolve_lib "${_wu_lib_name}.sh" "$_WU_BOOT_DIR"; then
        unset -f _wu_resolve_lib
        return 1 2>/dev/null || exit 1
    fi
done
unset -f _wu_resolve_lib
