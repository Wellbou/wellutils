#!/usr/bin/env bash
# bootstrap.sh -- shared library loader for wellutils tools
# Usage: source bootstrap.sh lang box cli [jedec]
# Sets _WU_BOOT_DIR to the resolved source directory.

# Resolve a library path. Runs in a command-substitution subshell, so it never
# mutates caller scope; the actual `source` happens at bootstrap's top level.
# this matters: sourcing a lib from inside a function makes any `declare -A`
# in that lib (e.g. lang.sh's _T_EN/_T_RU) function-local, so the arrays would
# vanish on return and all translations break -- on every bash >= 4, not just
# old ones. Always returns 0 so callers under `set -e` can test the path.
_wu_find_lib() {
    local name="$1" _dir="$2" _path
    _path="${_dir}/${name}"
    [[ -f "$_path" ]] || _path="$(dirname "$(dirname "$_dir")")/share/wellutils/${name}"
    [[ -f "$_path" ]] || _path="/usr/local/share/wellutils/${name}"
    [[ -f "$_path" ]] || _path="/usr/share/wellutils/${name}"
    [[ -f "$_path" ]] || _path="/etc/wellutils/${name}"
    [[ -f "$_path" ]] && printf '%s\n' "$_path"
    return 0
}

# Associative arrays and ${var,,} require bash 4 (macOS ships 3.2).
if (( BASH_VERSINFO[0] < 4 )); then
    printf 'wellutils: bash >= 4.0 required, found %s. On macOS: brew install bash\n' "$BASH_VERSION" >&2
    return 1 2>/dev/null || exit 1
fi

_WU_BOOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
for _wu_lib_name in "$@"; do
    _wu_lib_path="$(_wu_find_lib "${_wu_lib_name}.sh" "$_WU_BOOT_DIR")"
    if [[ -z "$_wu_lib_path" ]]; then
        printf 'wellutils: cannot find %s\n' "$_wu_lib_name" >&2
        return 1 2>/dev/null || exit 1
    fi
    source "$_wu_lib_path"
done
unset -f _wu_find_lib
unset _wu_lib_name _wu_lib_path