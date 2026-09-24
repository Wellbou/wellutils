#!/usr/bin/env bash
# bootstrap.sh -- shared library loader for wellutils tools
# Usage: source bootstrap.sh lang box cli [parse] [jedec]
# Sets _WU_BOOT_DIR to the resolved source directory.

# Associative arrays and ${var,,} require bash 4 (macOS ships 3.2).
if [ -z "${BASH_VERSINFO:-}" ] || [ "${BASH_VERSINFO[0]}" -lt 4 ]; then
    printf 'wellutils: bash >= 4.0 required, found %s. On macOS: brew install bash\n' "${BASH_VERSION:-none}" >&2
    return 1 2>/dev/null || exit 1
fi

# Resolve a library path into $_wu_lib_path (no subshell, no forks).
# Lookup order: the directory of this bootstrap.sh (= the tool's own tree:
# repo checkout or $PREFIX/share/wellutils), then <prefix>/share/wellutils
# derived from it, then the usual system locations.
# The actual `source` happens at bootstrap's top level on purpose: sourcing
# from inside a function would make `declare -A` in a lib (lang.sh's
# _T_EN/_T_RU) function-local, and translations would vanish on return.
_wu_find_lib() {
    local name="$1" dir="$2" up d
    up="${dir%/*}"; up="${up%/*}"
    _wu_lib_path=""
    for d in "$dir" "${up:-}/share/wellutils" "${PREFIX:+$PREFIX/share/wellutils}" \
             /usr/local/share/wellutils /usr/share/wellutils /etc/wellutils; do
        [[ -n "$d" && -f "$d/$name" ]] && { _wu_lib_path="$d/$name"; return 0; }
    done
    return 0
}

_WU_BOOT_DIR="${BASH_SOURCE[0]%/*}"
[[ "$_WU_BOOT_DIR" == "${BASH_SOURCE[0]}" ]] && _WU_BOOT_DIR="."
[[ "$_WU_BOOT_DIR" == /* ]] || _WU_BOOT_DIR="$(cd -- "$_WU_BOOT_DIR" && pwd)"
for _wu_lib_name in "$@"; do
    _wu_find_lib "${_wu_lib_name}.sh" "$_WU_BOOT_DIR"
    if [[ -z "$_wu_lib_path" ]]; then
        printf 'wellutils: cannot find %s.sh (looked in %s)\n' "$_wu_lib_name" "$_WU_BOOT_DIR" >&2
        return 1 2>/dev/null || exit 1
    fi
    source "$_wu_lib_path"
done
unset -f _wu_find_lib
unset _wu_lib_name _wu_lib_path
