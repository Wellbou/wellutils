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
    # Split on the FIRST colon only ("model name : Foo: Bar" keeps "Foo: Bar");
    # [ \t] instead of [[:space:]] -- mawk 1.3.3 (Debian <=10) lacks classes.
    _v=$(awk -v k="$key" '
        {
            i = index($0, ":"); if (i == 0) next
            f = substr($0, 1, i - 1)
            sub(/[ \t]+$/, "", f)
            if (tolower(f) == tolower(k)) {
                v = substr($0, i + 1)
                sub(/^[ \t]+/, "", v); sub(/[ \t\r]+$/, "", v)
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
    awk -v k="$key" '
        {
            i = index($0, ":"); if (i == 0) next
            f = substr($0, 1, i - 1)
            sub(/[ \t]+$/, "", f)
            if (tolower(f) == tolower(k)) {
                v = substr($0, i + 1)
                sub(/^[ \t]+/, "", v); sub(/[ \t\r]+$/, "", v)
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
    local s lc num frac="" unit mult
    s="${1// /}"
    [ -z "$s" ] && { printf 0; return; }
    lc=$(printf '%s' "$s" | LC_ALL=C tr 'A-Z' 'a-z')
    case "$lc" in
        *out*|*spec*|*unknown*|*n/a*|*none*|*no*module*|*\?*) printf 0; return ;;
    esac
    lc=${lc//,/.}                       # "7,8GiB" from a ru/de locale
    num=${lc%%[!0-9]*}
    [ -z "$num" ] && { printf 0; return; }
    unit=${lc:${#num}}
    if [[ "$unit" == .* ]]; then         # decimals: "7.8 GiB", "1.5T"
        frac=${unit#.}; frac=${frac%%[!0-9]*}; unit=${unit#.$frac}
    fi
    num=$((10#$num))
    case "$unit" in
        pib|pb|p) mult=$(( 1024 * 1024 * 1024 )) ;;
        tib|tb|t) mult=$(( 1024 * 1024 )) ;;
        gib|gb|g) mult=1024 ;;
        kib|kb|k) printf '%d' $(( num / 1024 )); return ;;
        *)        mult=1 ;;
    esac
    if [ -n "$frac" ]; then
        frac=${frac:0:3}; while (( ${#frac} < 3 )); do frac+=0; done
        printf '%d' $(( num * mult + (10#$frac) * mult / 1000 ))
    else
        printf '%d' $(( num * mult ))
    fi
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
    [[ "$s" =~ ([0-9]+) ]] || return 0
    printf '%s' "${BASH_REMATCH[1]}"
}


# ─── Fork-free helpers shared by every tool ─────────────────────────

# wu_read FILE [VAR]  -- first line of a sysfs/proc file, no cat/tr forks.
# Returns 1 (and empty) when unreadable (Termux/SELinux/containers).
wu_read() {
    local __wu_l=""
    { IFS= read -r __wu_l < "$1"; } 2>/dev/null || [[ -n "$__wu_l" ]] || { [[ -n "${2:-}" ]] && printf -v "$2" '%s' ""; return 1; }
    __wu_l=${__wu_l%$'\r'}
    if [[ -n "${2:-}" ]]; then printf -v "$2" '%s' "$__wu_l"; else printf '%s' "$__wu_l"; fi
}

# wu_trim STR [VAR] -- strip leading/trailing whitespace.
wu_trim() {
    local __wu_t="$1"
    __wu_t=${__wu_t#"${__wu_t%%[![:space:]]*}"}
    __wu_t=${__wu_t%"${__wu_t##*[![:space:]]}"}
    if [[ -n "${2:-}" ]]; then printf -v "$2" '%s' "$__wu_t"; else printf '%s' "$__wu_t"; fi
}

# wu_junk STR -- 0 when STR is a firmware placeholder, not real data.
# No-name RAM sticks and cheap boards fill SMBIOS with these.
wu_junk() {
    local _wj
    wu_trim "$1" _wj
    local _s=${_wj,,}
    case "$_s" in
        ""|unknown|"not specified"|"not available"|"not provided"|undefined|none|null|n/a|na|"-"|\
        "to be filled by o.e.m."|"to be filled by oem"|"default string"|"system product name"|\
        "system manufacturer"|"o.e.m."|oem|"system version"|"base board product name"|\
        "<out of spec>"|"out of spec"|"no module installed"|"not installed"|"empty"|\
        0|00|0000|00000000|0000000000000000|ffff|ffffffff|"ffffffffffffffff"|\
        manufacturer*|"modulepartnumber"*|"partnum"*|"serial number"*|"serialnum"*|"asset tag"*|\
        "123456789"|"1234567890"|"xxxxx"*|"none."|"no dimm"|"dimm_?") return 0 ;;
    esac
    return 1
}

# Decide once how (if at all) we can run privileged helpers. Checking
# `sudo -n true` per call costs a fork+exec each time (and wakes PAM).
# _WU_ROOT: 1 = we are root, 2 = passwordless sudo, 0 = neither.
wu_root_init() {
    [[ -n "${_WU_ROOT:-}" ]] && return 0
    if (( ${EUID:-$(id -u 2>/dev/null || echo 1)} == 0 )); then _WU_ROOT=1
    elif [[ -n "${TERMUX_VERSION:-}" ]]; then _WU_ROOT=0
    elif command -v sudo >/dev/null 2>&1 && sudo -n true 2>/dev/null; then _WU_ROOT=2
    else _WU_ROOT=0; fi
}
wu_root_run() {
    wu_root_init
    case "$_WU_ROOT" in
        1) "$@" ;;
        2) sudo -n "$@" ;;
        *) return 126 ;;
    esac
}

# wu_batteries -- print sysfs dirs of real system batteries, one per line.
# Classify by `type`, not by name: BAT0, CMB0, macsmc-battery (Asahi),
# axp20x-battery (PinePhone/SBC), battery (Android), bq27500-0 ...
# Peripheral batteries (mouse, gamepad) have scope=Device and are skipped.
wu_batteries() {
    local d ty sc
    for d in /sys/class/power_supply/*; do
        [[ -e "$d" ]] || continue
        wu_read "$d/type" ty || continue
        [[ "$ty" == Battery ]] || continue
        sc=System; wu_read "$d/scope" sc || sc=System
        [[ "$sc" == Device ]] && continue
        printf '%s\n' "$d"
    done
}
# wu_ac_adapters -- mains/USB-PD supplies (AC, ADP1, ACAD, axp20x-ac, ...).
wu_ac_adapters() {
    local d ty
    for d in /sys/class/power_supply/*; do
        [[ -e "$d" ]] || continue
        wu_read "$d/type" ty || continue
        case "$ty" in Mains|USB|USB_*|Wireless) printf '%s\n' "$d" ;; esac
    done
}

# wu_arm_part IMPL PART -- human name for an ARM MIDR implementer/part pair.
# Source: linux arch/arm64/include/asm/cputype.h (+ arm32 cputype.h).
wu_arm_part() {
    local impl="${1,,}" part="${2,,}"
    case "$impl/$part" in
        0x41/0xb02) echo "ARM11 MPCore" ;;  0x41/0xb36) echo "ARM1136" ;;
        0x41/0xb56) echo "ARM1156" ;;       0x41/0xb76) echo "ARM1176" ;;
        0x41/0xc05) echo "Cortex-A5" ;;     0x41/0xc07) echo "Cortex-A7" ;;
        0x41/0xc08) echo "Cortex-A8" ;;     0x41/0xc09) echo "Cortex-A9" ;;
        0x41/0xc0d) echo "Cortex-A12" ;;    0x41/0xc0c) echo "Cortex-A12" ;;
        0x41/0xc0e) echo "Cortex-A17" ;;    0x41/0xc0f) echo "Cortex-A15" ;;
        0x41/0xc0a) echo "Cortex-A15" ;;
        0x41/0xc14) echo "Cortex-R4" ;;     0x41/0xc15) echo "Cortex-R5" ;;
        0x41/0xc20) echo "Cortex-M0" ;;     0x41/0xc23) echo "Cortex-M3" ;;
        0x41/0xc24) echo "Cortex-M4" ;;
        0x41/0xd01) echo "Cortex-A32" ;;    0x41/0xd02) echo "Cortex-A34" ;;
        0x41/0xd03) echo "Cortex-A53" ;;    0x41/0xd04) echo "Cortex-A35" ;;
        0x41/0xd05) echo "Cortex-A55" ;;    0x41/0xd06) echo "Cortex-A65" ;;
        0x41/0xd07) echo "Cortex-A57" ;;    0x41/0xd08) echo "Cortex-A72" ;;
        0x41/0xd09) echo "Cortex-A73" ;;    0x41/0xd0a) echo "Cortex-A75" ;;
        0x41/0xd0b) echo "Cortex-A76" ;;    0x41/0xd0c) echo "Neoverse-N1" ;;
        0x41/0xd0d) echo "Cortex-A77" ;;    0x41/0xd0e) echo "Cortex-A76AE" ;;
        0x41/0xd13) echo "Cortex-R52" ;;    0x41/0xd15) echo "Cortex-R82" ;;
        0x41/0xd40) echo "Neoverse-V1" ;;   0x41/0xd41) echo "Cortex-A78" ;;
        0x41/0xd42) echo "Cortex-A78AE" ;;  0x41/0xd43) echo "Cortex-A65AE" ;;
        0x41/0xd44) echo "Cortex-X1" ;;     0x41/0xd46) echo "Cortex-A510" ;;
        0x41/0xd47) echo "Cortex-A710" ;;   0x41/0xd48) echo "Cortex-X2" ;;
        0x41/0xd49) echo "Neoverse-N2" ;;   0x41/0xd4a) echo "Neoverse-E1" ;;
        0x41/0xd4b) echo "Cortex-A78C" ;;   0x41/0xd4c) echo "Cortex-X1C" ;;
        0x41/0xd4d) echo "Cortex-A715" ;;   0x41/0xd4e) echo "Cortex-X3" ;;
        0x41/0xd4f) echo "Neoverse-V2" ;;   0x41/0xd80) echo "Cortex-A520" ;;
        0x41/0xd81) echo "Cortex-A720" ;;   0x41/0xd82) echo "Cortex-X4" ;;
        0x41/0xd84) echo "Neoverse-V3" ;;   0x41/0xd85) echo "Cortex-X925" ;;
        0x41/0xd87) echo "Cortex-A725" ;;   0x41/0xd8e) echo "Neoverse-N3" ;;
        0x42/0x00f) echo "Broadcom Brahma-B15" ;; 0x42/0x100) echo "Broadcom Brahma-B53" ;;
        0x42/0x516) echo "Broadcom Vulcan" ;;
        0x43/0x0a1) echo "Cavium ThunderX" ;;     0x43/0x0af) echo "Cavium ThunderX2" ;;
        0x43/0x0b8) echo "Marvell ThunderX3" ;;
        0x46/0x001) echo "Fujitsu A64FX" ;;
        0x48/0xd01) echo "HiSilicon TaiShan v110 (Kunpeng 920)" ;;
        0x48/0xd02) echo "HiSilicon TaiShan v120" ;;
        0x4e/0x000) echo "NVIDIA Denver" ;;       0x4e/0x003) echo "NVIDIA Denver 2" ;;
        0x4e/0x004) echo "NVIDIA Carmel" ;;
        0x50/0x000) echo "APM X-Gene" ;;
        0x51/0x00f) echo "Qualcomm Scorpion" ;;   0x51/0x02d) echo "Qualcomm Scorpion" ;;
        0x51/0x04d) echo "Qualcomm Krait" ;;      0x51/0x06f) echo "Qualcomm Krait" ;;
        0x51/0x200) echo "Qualcomm Kryo" ;;       0x51/0x201) echo "Qualcomm Kryo Silver" ;;
        0x51/0x205) echo "Qualcomm Kryo Gold" ;;  0x51/0x211) echo "Qualcomm Kryo" ;;
        0x51/0x800) echo "Qualcomm Kryo 2xx Gold" ;;  0x51/0x801) echo "Qualcomm Kryo 2xx Silver" ;;
        0x51/0x802) echo "Qualcomm Kryo 3xx Gold" ;;  0x51/0x803) echo "Qualcomm Kryo 3xx Silver" ;;
        0x51/0x804) echo "Qualcomm Kryo 4xx Gold" ;;  0x51/0x805) echo "Qualcomm Kryo 4xx Silver" ;;
        0x51/0xc00) echo "Qualcomm Falkor" ;;     0x51/0xc01) echo "Qualcomm Saphira" ;;
        0x51/0x001) echo "Qualcomm Oryon" ;;
        0x53/0x001) echo "Samsung Exynos M1" ;;   0x53/0x002) echo "Samsung Exynos M3" ;;
        0x56/0x131) echo "Marvell Feroceon" ;;    0x56/0x581) echo "Marvell PJ4" ;;
        0x61/0x020) echo "Apple A14 Icestorm" ;;  0x61/0x021) echo "Apple A14 Firestorm" ;;
        0x61/0x022) echo "Apple M1 Icestorm" ;;   0x61/0x023) echo "Apple M1 Firestorm" ;;
        0x61/0x024) echo "Apple M1 Pro Icestorm" ;; 0x61/0x025) echo "Apple M1 Pro Firestorm" ;;
        0x61/0x028) echo "Apple M1 Max Icestorm" ;; 0x61/0x029) echo "Apple M1 Max Firestorm" ;;
        0x61/0x030) echo "Apple A15 Blizzard" ;;  0x61/0x031) echo "Apple A15 Avalanche" ;;
        0x61/0x032) echo "Apple M2 Blizzard" ;;   0x61/0x033) echo "Apple M2 Avalanche" ;;
        0x61/0x034) echo "Apple M2 Pro Blizzard" ;; 0x61/0x035) echo "Apple M2 Pro Avalanche" ;;
        0x61/0x038) echo "Apple M2 Max Blizzard" ;; 0x61/0x039) echo "Apple M2 Max Avalanche" ;;
        0x66/0x526) echo "Faraday FA526" ;;
        0x69/0x200) echo "Intel XScale" ;;
        0x6d/0xd49) echo "Microsoft Azure Cobalt 100" ;;
        0x70/0x303) echo "Phytium FTC310" ;;      0x70/0x660) echo "Phytium FTC660" ;;
        0x70/0x661) echo "Phytium FTC661" ;;      0x70/0x662) echo "Phytium FTC662" ;;
        0x70/0x663) echo "Phytium FTC663" ;;      0x70/0x664) echo "Phytium FTC664" ;;
        0xc0/0xac3) echo "Ampere-1" ;;            0xc0/0xac4) echo "Ampere-1A" ;;
        *) return 1 ;;
    esac
}
wu_arm_vendor() {
    case "${1,,}" in
        0x41) echo ARM ;; 0x42) echo Broadcom ;; 0x43) echo Cavium ;; 0x44) echo DEC ;;
        0x46) echo Fujitsu ;; 0x48) echo HiSilicon ;; 0x49) echo Infineon ;;
        0x4d) echo Motorola ;; 0x4e) echo NVIDIA ;; 0x50) echo APM ;; 0x51) echo Qualcomm ;;
        0x53) echo Samsung ;; 0x56) echo Marvell ;; 0x61) echo Apple ;; 0x66) echo Faraday ;;
        0x69) echo Intel ;; 0x6d) echo Microsoft ;; 0x70) echo Phytium ;; 0xc0) echo Ampere ;;
        *) echo "CPU" ;;
    esac
}

# wu_dt_model -- board/SoC name from the device tree (ARM, PPC, MIPS,
# RISC-V boards, Asahi Macs). Empty when there is no DT.
wu_dt_model() {
    local f m=""
    for f in /proc/device-tree/model /sys/firmware/devicetree/base/model; do
        [[ -r "$f" ]] || continue
        m=$(tr -d '\000' < "$f" 2>/dev/null) && [[ -n "$m" ]] && break
    done
    printf '%s' "$m"
}

# wu_cpu_model_generic -- best-effort CPU name on any architecture, from
# /proc/cpuinfo only (x86, LoongArch, POWER/Xenon, s390, MIPS, RISC-V, ARM,
# SPARC, Alpha, m68k, SuperH) with device-tree fallback. One awk pass.
wu_cpu_model_generic() {
    local f=/proc/cpuinfo m="" k impl part parts p n line out="" dt
    if [[ -r "$f" ]]; then
        for k in "model name" "cpu model" "cpu" "processor" "Processor" "uarch" "cpu type" "system type"; do
            m=$(wu_kv "$f" "$k")
            case "$k" in
                processor|Processor) [[ "$m" =~ ^[0-9]+$ ]] && m="" ;;   # "processor : 0" is an index
                cpu) m=${m%%,*} ;;                                     # "POWER9 (raw), altivec supported"
            esac
            [[ -n "$m" ]] && break
        done
        impl=$(wu_kv "$f" "CPU implementer")
        if [[ -n "$impl" ]]; then
            # ARM: group distinct parts -> "4× Cortex-A55 + 4× Cortex-A76"
            parts=$(awk -F: 'tolower($1) ~ /^cpu part/ {gsub(/[ \t]/,"",$2); c[tolower($2)]++}
                             END {for (p in c) print c[p], p}' "$f" 2>/dev/null | sort -k2)
            while read -r n p; do
                [[ -n "$p" ]] || continue
                line=$(wu_arm_part "$impl" "$p") || line="$(wu_arm_vendor "$impl") part $p"
                [[ -n "$out" ]] && out+=" + "
                out+="${n}× ${line}"
            done <<< "$parts"
            # count==1 group: drop the "N× " prefix for readability
            [[ "$out" != *" + "* ]] && out=${out#*× }
            k=$(wu_kv "$f" "Hardware")
            [[ -z "$k" ]] && k=$(wu_dt_model)
            if [[ -n "$out" ]]; then m="${k:+$k (}${out}${k:+)}"; elif [[ -n "$k" ]]; then m=$k; fi
        fi
    fi
    if [[ -z "$m" ]]; then
        dt=$(wu_dt_model); m=$dt
    fi
    [[ -z "$m" ]] && m=$(uname -m 2>/dev/null)
    wu_trim "$m" m
    printf '%s' "$m"
}

# wu_os_pretty -- distro name on anything: os-release (both locations,
# Termux $PREFIX), legacy release files, Android getprop.
wu_os_pretty() {
    local f v line
    for f in "${WF_OSFILE:-}" /etc/os-release /usr/lib/os-release "${PREFIX:-/nonexistent}/etc/os-release"; do
        [[ -n "$f" && -r "$f" ]] || continue
        while IFS= read -r line; do
            case "$line" in PRETTY_NAME=*) v=${line#PRETTY_NAME=}; v=${v//\"/}; v=${v//\'/}; break ;; esac
        done < "$f"
        [[ -n "${v:-}" ]] && { printf '%s' "$v"; return 0; }
    done
    if [[ "$(uname -o 2>/dev/null)" == Android ]] || [[ -n "${TERMUX_VERSION:-}" ]]; then
        v=$(getprop ro.build.version.release 2>/dev/null)
        printf 'Android%s' "${v:+ $v}"; return 0
    fi
    for f in /etc/redhat-release /etc/SuSE-release /etc/slackware-version /etc/gentoo-release /etc/alpine-release /etc/debian_version; do
        [[ -r "$f" ]] || continue
        wu_read "$f" v
        case "$f" in
            */alpine-release) v="Alpine Linux $v" ;;
            */debian_version) v="Debian $v" ;;
        esac
        [[ -n "$v" ]] && { printf '%s' "$v"; return 0; }
    done
    if [[ -r /etc/lsb-release ]]; then
        v=$(wu_kv /etc/lsb-release DISTRIB_DESCRIPTION 2>/dev/null)
        [[ -z "$v" ]] && v=$(sed -n 's/^DISTRIB_DESCRIPTION=//p' /etc/lsb-release | tr -d '"')
        [[ -n "$v" ]] && { printf '%s' "$v"; return 0; }
    fi
    uname -s 2>/dev/null || printf 'Linux'
}
