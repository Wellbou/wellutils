#!/usr/bin/env bash
# parse.sh -- shared text/file parsers for wellutils
# Public helpers:
#   wu_kv FILE KEY [DEFAULT]
#   wu_kv_all FILE KEY
#   wu_size_mb STR
#   wu_speed STR
# shellcheck shell=bash

# wu_kv FILE KEY [DEFAULT]
#   First value of a colon-keyed record from /proc-style files.
#   - Case-insensitive field name match (x86 "model name" == LoongArch "Model Name").
#   - Tolerates the kernel's tab between name and colon (wellcpu U6).
#   - Strips leading whitespace from the returned value.
#   - DEFAULT (empty by default) is returned when the file is unreadable,
#     the field is absent, or the awk pipeline fails (set -e / pipefail safe).
#   - Implementation uses one awk process, no greps.
wu_kv() {
    local file="$1" key="$2" default="${3:-}" _v
    _v=$(awk -F': *' -v k="$key" '
        {
            f = $1
            sub(/[[:space:]]+$/, "", f)
            if (tolower(f) == tolower(k)) {
                v = $2
                sub(/^[[:space:]]+/, "", v)
                print v
                exit
            }
        }' "$file" 2>/dev/null) || _v=""
    printf '%s' "${_v:-$default}"
}

# wu_kv_all FILE KEY
#   All values of a colon-keyed field, one per line (preserves order).
#   Useful for fields that repeat per processor (CPU part on big.LITTLE,
#   vendor_id for multi-socket x86, "BogoMIPS", "Features", ...).
wu_kv_all() {
    local file="$1" key="$2"
    awk -F': *' -v k="$key" '
        {
            f = $1
            sub(/[[:space:]]+$/, "", f)
            if (tolower(f) == tolower(k)) {
                v = $2
                sub(/^[[:space:]]+/, "", v)
                print v
            }
        }' "$file" 2>/dev/null || true
}

# wu_size_mb STR
#   Normalize a size string to MiB (1 MiB = 1024^2 bytes).
#   Accepts:
#     "8 GB" / "8G" / "8GiB" / "8T" -> 8 * 1024 = 8192 (GiB) or 8388608 (TiB)
#     "8192 MB" / "8192M" / "8MiB"   -> 8192
#     "4096 KB" / "4K"               -> 4
#     "64" (no unit)                  -> 64 (treated as MiB)
#     "" / "<OUT OF SPEC>" / "?"     -> 0
#   Notes: dmidecode uses "MB" to mean 2^20; we follow that convention so a
#   direct port from the old T7/T8 aggregator stays byte-identical.
wu_size_mb() {
    local s lc num unit
    s="${1// /}"
    [ -z "$s" ] && { printf 0; return; }
    lc=$(printf '%s' "$s" | tr 'A-Z' 'a-z')
    case "$lc" in
        *out*|*spec*|*unknown*|*n/a*|*\?*) printf 0; return ;;
    esac
    num=${lc%%[!0-9]*}
    [ -z "$num" ] && { printf 0; return; }
    unit=${lc:${#num}}
    case "$unit" in
        pib|pb|p) printf '%d' $(( num * 1024 * 1024 * 1024 * 1024 )) ;;
        tib|tb|t) printf '%d' $(( num * 1024 * 1024 )) ;;
        gib|gb|g) printf '%d' $(( num * 1024 )) ;;
        mib|mb|m) printf '%d' $(( num )) ;;
        kib|kb|k) printf '%d' $(( num / 1024 )) ;;
        *)        printf '%d' $(( num )) ;;
    esac
}

# wu_speed STR
#   Extract the first integer speed value from a string.
#   "4800 MT/s"      -> 4800   (DDR5)
#   "1600 MT/s"      -> 1600   (DDR3)
#   "133 MHz (7.5 ns)" -> 133  (retro SDRAM; previously dropped by wellhw)
#   "DDR4-3200"      -> 3200
#   "" / "?"         -> empty
#   When the input is empty or has no digits, prints nothing.
wu_speed() {
    local s="$1" n
    # First integer in the string (avoids concat like "1.5" -> 1 and
    # "133 MHz (7.5 ns)" -> 133, not "13375").
    n=$(printf '%s' "$s" | grep -oE '[0-9]+' | head -1) || n=""
    [ -z "$n" ] && return 0
    printf '%s' "$n"
}
