# box.sh -- shared adaptive box-drawing engine for wellutils
# Part of wellutils by wellbou_
# Depends on: lang.sh (source it first -- provides t())
# shellcheck shell=bash

# ─── Colors & Symbols ───────────────────────────────────────────
R=$'\033[1;31m'  G=$'\033[1;32m'  Y=$'\033[1;33m'  B=$'\033[1;34m'
M=$'\033[1;35m'  C=$'\033[1;36m'  W=$'\033[1;37m'  DIM=$'\033[2m'
BOLD=$'\033[1m'  RESET=$'\033[0m'

# ─── ASCII fallbacks for Unicode block elements ─────────────
# Usage: wu_bar FILLED EMPTY  -- prints a progress bar using Unicode or ASCII.
wu_bar() {
    local filled="${1:-0}" empty="${2:-0}" f e
    (( filled < 0 )) && filled=0; (( empty < 0 )) && empty=0
    printf -v f '%*s' "$filled" ''; printf -v e '%*s' "$empty" ''
    if [[ "${_WU_UNICODE:-1}" -eq 1 ]]; then
        printf '%s%s' "${f// /█}" "${e// /░}"
    else
        printf '%s%s' "${f// /#}" "${e// /.}"
    fi
}

# wu_scale  -- prints one of 8 bar-height glyphs (▁▂▃▄▅▆▇█) or ASCII fallback.
wu_scale() {
    local idx="${1:-0}"
    if [[ "${_WU_UNICODE:-1}" -eq 1 ]]; then
        local bars=("▁" "▂" "▃" "▄" "▅" "▆" "▇" "█")
        printf '%s' "${bars[$(( idx < 0 ? 0 : idx > 7 ? 7 : idx ))]}"
    else
        local bars=("." "." "." "-" "-" "=" "=" "#")
        printf '%s' "${bars[$(( idx < 0 ? 0 : idx > 7 ? 7 : idx ))]}"
    fi
}

# ─── GPU AIB vendor detection ────────────────────────────────────
# Reads subsystem_vendor from sysfs for a PCI bus address.
gpu_aib_vendor() {
    local bus="$1" hex _dev
    # Keep non-zero PCI domains (0001:01:00.0 on POWER/ARM servers, VMD).
    [[ "$bus" == *:*:* ]] || bus="0000:${bus}"
    _dev="/sys/bus/pci/devices/${bus}"
    [[ -d "$_dev" ]] || _dev=$(find /sys/bus/pci/devices/ -maxdepth 1 -name "*:${bus}" -type d 2>/dev/null | head -1)
    [[ -d "$_dev" ]] || { printf ''; return; }
    hex=$(cat "${_dev}/subsystem_vendor" 2>/dev/null) || { printf ''; return; }
    hex="${hex#0x}"
    case "$hex" in
        1043) printf 'ASUS'       ;;
        1462) printf 'MSI'        ;;
        1458) printf 'Gigabyte'   ;;
        3842) printf 'EVGA'       ;;
        19da) printf 'ZOTAC'      ;;
        1569) printf 'Palit'      ;;
        148c) printf 'PowerColor' ;;
        1682) printf 'XFX'        ;;
        1da2) printf 'Sapphire'   ;;
        196e) printf 'PNY'        ;;
        1b4c) printf 'GALAX'      ;;
        10de) printf 'NVIDIA'     ;;
        1002) printf 'AMD'        ;;
        8086) printf 'Intel'      ;;
        102b) printf 'Matrox'     ;;
        1039) printf 'SiS'        ;;
        100c) printf 'ATI'        ;;
        109e) printf 'Brooktree'  ;;
        1102) printf 'Creative'   ;;
        1106) printf 'VIA'        ;;
        1260) printf 'Weitek'     ;;
        14af) printf 'Guillemot'   ;;
        1554) printf 'Brooktree'  ;;
        18ca) printf 'XGI'        ;;
        1de1) printf 'Trident'    ;;
        2720) printf 'Glenfly'    ;;
        *)   printf ''            ;;
    esac
}

# ─── pci.ids lookup (works without lspci) ────────────────────────
# _WU_PCI_IDS: path of the pci.ids database ("" when absent).
_WU_PCI_IDS=""
for _wu_p in /usr/share/hwdata/pci.ids /usr/share/misc/pci.ids /usr/share/pci.ids \
             /usr/local/share/hwdata/pci.ids /usr/local/share/pci.ids "${PREFIX:-/nonexistent}/share/hwdata/pci.ids"; do
    [[ -r "$_wu_p" ]] && { _WU_PCI_IDS=$_wu_p; break; }
done
unset _wu_p

# wu_pci_lookup Q... -- ONE awk pass over pci.ids for many devices.
# Q = "vid:did[:classhex]" (lowercase hex, no 0x). Prints one line per
# resolved query: "Q<TAB>vendor<TAB>device<TAB>class-name" (fields may be
# empty). mawk-safe (no {n} intervals, no [[:space:]]).
wu_pci_lookup() {
    [[ -n "$_WU_PCI_IDS" && $# -gt 0 ]] || return 0
    awk -v q="$*" '
    BEGIN { n = split(q, Q, " ")
            for (i = 1; i <= n; i++) { split(Q[i], p, ":"); V[p[1]] = 1; D[p[1] ":" p[2]] = 1
                                       if (p[3] != "") { C[substr(p[3],1,2)] = 1; S[substr(p[3],1,4)] = 1 } } }
    /^#/ || /^$/ { next }
    /^C / { mode = 2; cc = $2; if (cc in C) cname[cc] = substr($0, 7); next }
    mode == 2 {
        if ($0 ~ /^\t[0-9a-f][0-9a-f] / && ((cc substr($0,2,2)) in S)) sname[cc substr($0,2,2)] = substr($0, 6)
        next }
    /^[0-9a-f][0-9a-f][0-9a-f][0-9a-f] / { cv = $1; if (cv in V) vname[cv] = substr($0, 7); next }
    /^\t[0-9a-f][0-9a-f][0-9a-f][0-9a-f] / { k = cv ":" substr($0, 2, 4); if (k in D) dname[k] = substr($0, 8); next }
    END { for (i = 1; i <= n; i++) { split(Q[i], p, ":"); k = p[1] ":" p[2]
              c = ""; if (p[3] != "") { c = sname[substr(p[3],1,4)]; if (c == "") c = cname[substr(p[3],1,2)] }
              printf "%s\t%s\t%s\t%s\n", Q[i], vname[p[1]], dname[k], c } }
    ' "$_WU_PCI_IDS" 2>/dev/null || true
}

# wu_pci_name VID DID -- "Vendor Device" from pci.ids ("" if unknown).
wu_pci_name() {
    local v="${1#0x}" d="${2#0x}" r q vn dn
    r=$(wu_pci_lookup "${v,,}:${d,,}")
    IFS=$'\t' read -r q vn dn _ <<< "$r"
    [[ -n "$vn$dn" ]] && printf '%s' "${vn}${vn:+${dn:+ }}${dn}"
    return 0
}

# ─── PCI slot device filter ──────────────────────────────────────
# Populates global arrays: _PCI_BUS[], _PCI_CLASS[], _PCI_DESC[]
# Shows expansion card class devices only, filtering out chipset.
# Descriptions: one `lspci -D` call for all devices (was one per device),
# falling back to pci.ids ("Class: Vendor Device") when lspci is missing.
pci_slot_devices() {
    _PCI_BUS=() _PCI_CLASS=() _PCI_DESC=()
    local d addr bus major sub class_hex vid did l i q
    local -a qs=()
    for d in /sys/bus/pci/devices/*; do
        [[ -d "$d" ]] || continue
        addr=${d##*/}
        bus=${addr#*:}; bus=${bus%%:*}
        class_hex=""; { read -r class_hex < "$d/class"; } 2>/dev/null || [[ -n "$class_hex" ]] || continue
        class_hex="${class_hex#0x}"
        major="${class_hex:0:2}" sub="${class_hex:2:2}"

        # always skip bridges, memory, processors, SMBus, FireWire/serial
        case "$major" in 06|05|0b) continue ;; esac
        [[ "$major" == "0c" && ( "$sub" == "05" || "$sub" == "00" ) ]] && continue

        # always show: Display(03xx), Wireless(0dxx), RAID(0104), NVMe(0108)
        if [[ "$major" != "03" && "$major" != "0d" && ! ( "$major" == "01" && ( "$sub" == "04" || "$sub" == "08" ) ) ]]; then
            # bus 00: hide remaining chipset classes; bus >00: hide embedded
            # storage/network/comm/USB, keep audio (GPU HDMI audio, sound cards)
            [[ "$bus" == "00" ]] && continue
            case "$major" in 01|02|07|0c) continue ;; esac
        fi
        vid=""; did=""
        { read -r vid < "$d/vendor"; read -r did < "$d/device"; } 2>/dev/null || true
        _PCI_BUS+=("$addr"); _PCI_CLASS+=("$class_hex"); _PCI_DESC+=("")
        vid=${vid#0x} did=${did#0x}
        qs+=("${vid,,}:${did,,}:${class_hex:0:4}")
    done
    (( ${#_PCI_BUS[@]} )) || return 0
    if command -v lspci >/dev/null 2>&1; then
        local lsout
        lsout=$(lspci -D 2>/dev/null) || lsout=""
        while IFS= read -r l; do
            [[ -n "$l" ]] || continue
            for (( i = 0; i < ${#_PCI_BUS[@]}; i++ )); do
                [[ "${l%% *}" == "${_PCI_BUS[i]}" ]] && { _PCI_DESC[i]=${l#* }; break; }
            done
        done <<< "$lsout"
    fi
    local need=0 r vn dn cn
    for (( i = 0; i < ${#_PCI_BUS[@]}; i++ )); do [[ -z "${_PCI_DESC[i]}" ]] && need=1; done
    (( need )) || return 0
    while IFS=$'\t' read -r q vn dn cn; do
        [[ -n "$q" ]] || continue
        for (( i = 0; i < ${#_PCI_BUS[@]}; i++ )); do
            [[ -z "${_PCI_DESC[i]}" && "${qs[i]}" == "$q" ]] || continue
            r="${vn}${vn:+${dn:+ }}${dn}"
            [[ -z "$r" ]] && r="[${q%:*}]"
            _PCI_DESC[i]="${cn:+$cn: }$r"
        done
    done < <(wu_pci_lookup ${qs[@]+"${qs[@]}"})
    for (( i = 0; i < ${#_PCI_BUS[@]}; i++ )); do
        [[ -z "${_PCI_DESC[i]}" ]] && _PCI_DESC[i]="[${qs[i]%:*}]"
    done
    return 0
}

# ─── Adaptive box engine ────────────────────────────────────────
# Every section is a rounded-corner box whose width always fits the
# longest content line (long strings no longer overflow the frame).
_LINES=()
# Set _WU_PLAIN=1 to render sections without box drawing (plain text).
_WU_PLAIN=${_WU_PLAIN:-0}

# East-Asian-Wide test for a decoded code point (Unicode 16 tables, the same
# data glibc/musl wcwidth() and every modern terminal use). Emoji that are
# only *text*-presentation (🖥 🌡 ⚙ ⚠ ...) are width 1 once VS16 is stripped
# (cli.sh _emoji_clean does that), so they are deliberately NOT listed here.
_wu_wide() {
    local c=$1
    if (( c < 0x1100 )); then return 1; fi
    if (( c <= 0x115f || (c >= 0x2e80 && c <= 0xa4cf && c != 0x303f) || (c >= 0xa960 && c <= 0xa97c) \
       || (c >= 0xac00 && c <= 0xd7a3) || (c >= 0xf900 && c <= 0xfaff) || (c >= 0xfe10 && c <= 0xfe19) \
       || (c >= 0xfe30 && c <= 0xfe6f) || (c >= 0xff00 && c <= 0xff60) || (c >= 0xffe0 && c <= 0xffe6) \
       || (c >= 0x16fe0 && c <= 0x18cff) || (c >= 0x1aff0 && c <= 0x1b2ff) || (c >= 0x20000 && c <= 0x3fffd) )); then
        return 0
    fi
    if (( c >= 0x2300 && c <= 0x2bff )); then
        (( c==0x231a||c==0x231b||c==0x2329||c==0x232a||(c>=0x23e9&&c<=0x23ec)||c==0x23f0||c==0x23f3 \
         ||c==0x25fd||c==0x25fe||c==0x2614||c==0x2615||(c>=0x2630&&c<=0x2637)||(c>=0x2648&&c<=0x2653) \
         ||c==0x267f||(c>=0x268a&&c<=0x268f)||c==0x2693||c==0x26a1||c==0x26aa||c==0x26ab||c==0x26bd \
         ||c==0x26be||c==0x26c4||c==0x26c5||c==0x26ce||c==0x26d4||c==0x26ea||c==0x26f2||c==0x26f3 \
         ||c==0x26f5||c==0x26fa||c==0x26fd||c==0x2705||c==0x270a||c==0x270b||c==0x2728||c==0x274c \
         ||c==0x274e||(c>=0x2753&&c<=0x2755)||c==0x2757||(c>=0x2795&&c<=0x2797)||c==0x27b0||c==0x27bf \
         ||c==0x2b1b||c==0x2b1c||c==0x2b50||c==0x2b55 ))
        return
    fi
    if (( c >= 0x1f000 && c <= 0x1faff )); then
        (( c==0x1f004||c==0x1f0cf||c==0x1f18e||(c>=0x1f191&&c<=0x1f19a)||(c>=0x1f200&&c<=0x1f202) \
         ||(c>=0x1f210&&c<=0x1f23b)||(c>=0x1f240&&c<=0x1f248)||c==0x1f250||c==0x1f251||(c>=0x1f260&&c<=0x1f265) \
         ||(c>=0x1f300&&c<=0x1f320)||(c>=0x1f32d&&c<=0x1f335)||(c>=0x1f337&&c<=0x1f37c)||(c>=0x1f37e&&c<=0x1f393) \
         ||(c>=0x1f3a0&&c<=0x1f3ca)||(c>=0x1f3cf&&c<=0x1f3d3)||(c>=0x1f3e0&&c<=0x1f3f0)||c==0x1f3f4 \
         ||(c>=0x1f3f8&&c<=0x1f43e)||c==0x1f440||(c>=0x1f442&&c<=0x1f4fc)||(c>=0x1f4ff&&c<=0x1f53d) \
         ||(c>=0x1f54b&&c<=0x1f54e)||(c>=0x1f550&&c<=0x1f567)||c==0x1f57a||c==0x1f595||c==0x1f596||c==0x1f5a4 \
         ||(c>=0x1f5fb&&c<=0x1f64f)||(c>=0x1f680&&c<=0x1f6c5)||c==0x1f6cc||(c>=0x1f6d0&&c<=0x1f6d2) \
         ||(c>=0x1f6d5&&c<=0x1f6d7)||(c>=0x1f6dc&&c<=0x1f6df)||c==0x1f6eb||c==0x1f6ec||(c>=0x1f6f4&&c<=0x1f6fc) \
         ||(c>=0x1f7e0&&c<=0x1f7eb)||c==0x1f7f0||(c>=0x1f90c&&c<=0x1f93a)||(c>=0x1f93c&&c<=0x1f945) \
         ||(c>=0x1f947&&c<=0x1f9ff)||(c>=0x1fa70&&c<=0x1fa7c)||(c>=0x1fa80&&c<=0x1fa89)||(c>=0x1fa8f&&c<=0x1fac6) \
         ||(c>=0x1face&&c<=0x1fadc)||(c>=0x1fadf&&c<=0x1fae9)||(c>=0x1faf0&&c<=0x1faf8) ))
        return
    fi
    return 1
}

# Zero-width code points: combining marks, ZWJ/ZWNJ, variation selectors,
# skin-tone modifiers are width 2 on their own but 0 after an emoji (handled
# by the caller treating them as part of the previous cluster).
_wu_zero() {
    local c=$1
    (( (c >= 0x300 && c <= 0x36f) || (c >= 0x483 && c <= 0x489) || (c >= 0x591 && c <= 0x5bd) \
     || (c >= 0x610 && c <= 0x61a) || (c >= 0x64b && c <= 0x65f) || (c >= 0x1ab0 && c <= 0x1aff) \
     || (c >= 0x1dc0 && c <= 0x1dff) || (c >= 0x200b && c <= 0x200f) || (c >= 0x2028 && c <= 0x202e) \
     || (c >= 0x2060 && c <= 0x2064) || (c >= 0x20d0 && c <= 0x20ff) || (c >= 0xfe00 && c <= 0xfe0f) \
     || (c >= 0xfe20 && c <= 0xfe2f) || c == 0xfeff || (c >= 0x1f3fb && c <= 0x1f3ff) \
     || (c >= 0xe0000 && c <= 0xe0fff) ))
}

# Classify one character at byte index $2 of string $1 (caller runs LC_ALL=C).
# Writes bytes-to-advance and display width to $_WU_ADV and $_WU_W.
# ANSI CSI sequences are skipped whole (width 0). Emoji ZWJ chains and
# regional-indicator flag pairs collapse to one width-2 cluster.
# `& 0xff`: musl's printf "'<byte>" yields 0xDF00|byte for high bytes
# (Alpine, Void-musl, postmarketOS, OpenWrt) -- mask it back to a byte.
_wuchar() {
    local s="$1" i="$2" b b2 b3 b4 cp j n=${#1}
    printf -v b '%d' "'${s:i:1}"; b=$(( b & 0xff ))
    if (( b < 0x80 )); then
        if (( b == 0x1b )) && [[ "${s:i+1:1}" == "[" ]]; then
            j=$(( i + 2 ))
            while (( j < n )); do
                printf -v b2 '%d' "'${s:j:1}"; b2=$(( b2 & 0xff ))
                (( b2 >= 0x40 && b2 <= 0x7e )) && break
                j=$(( j + 1 ))
            done
            _WU_ADV=$(( j - i + 1 )); _WU_W=0
        elif (( b < 0x20 || b == 0x7f )); then
            _WU_ADV=1; _WU_W=0
        else
            _WU_ADV=1; _WU_W=1
        fi
        return
    fi
    if (( b < 0xc0 )); then _WU_ADV=1; _WU_W=0; return; fi       # stray continuation byte
    printf -v b2 '%d' "'${s:i+1:1}"; b2=$(( b2 & 0x3f ))
    if (( b < 0xe0 )); then
        cp=$(( ((b & 0x1f) << 6) | b2 )); _WU_ADV=2
    elif (( b < 0xf0 )); then
        printf -v b3 '%d' "'${s:i+2:1}"; b3=$(( b3 & 0x3f ))
        cp=$(( ((b & 0x0f) << 12) | (b2 << 6) | b3 )); _WU_ADV=3
    else
        printf -v b3 '%d' "'${s:i+2:1}"; printf -v b4 '%d' "'${s:i+3:1}"
        cp=$(( ((b & 0x07) << 18) | (b2 << 12) | ((b3 & 0x3f) << 6) | (b4 & 0x3f) )); _WU_ADV=4
    fi
    if _wu_zero "$cp"; then _WU_W=0; return; fi
    if _wu_wide "$cp"; then _WU_W=2; else _WU_W=1; fi
    # Emoji + VS16 (U+FE0F) is rendered wide by terminals.
    if [[ "${s:i+_WU_ADV:3}" == $'\xef\xb8\x8f' ]]; then _WU_W=2; _WU_ADV=$(( _WU_ADV + 3 )); fi
    # Regional-indicator pair (flag) -> one width-2 cluster.
    if (( cp >= 0x1f1e6 && cp <= 0x1f1ff )); then
        _WU_W=1
        if [[ "${s:i+4:3}" == $'\xf0\x9f\x87' ]]; then _WU_ADV=8; _WU_W=2; fi
        return
    fi
    # ZWJ chain: swallow "ZWJ + next glyph" repeatedly, width of the first.
    while [[ "${s:i+_WU_ADV:3}" == $'\xe2\x80\x8d' ]]; do
        j=$(( i + _WU_ADV + 3 ))
        printf -v b '%d' "'${s:j:1}"; b=$(( b & 0xff ))
        if   (( b >= 0xf0 )); then j=$(( j + 4 ))
        elif (( b >= 0xe0 )); then j=$(( j + 3 ))
        elif (( b >= 0xc0 )); then j=$(( j + 2 ))
        else j=$(( j + 1 )); fi
        [[ "${s:j:3}" == $'\xef\xb8\x8f' ]] && j=$(( j + 3 ))
        _WU_ADV=$(( j - i ))
    done
}

# Strip ANSI CSI sequences (fork-free).
_wu_strip_ansi() {
    local s="$1" pre rest
    while [[ "$s" == *$'\033['* ]]; do
        pre=${s%%$'\033['*}; rest=${s#*$'\033['}
        rest=${rest#*[@-~]}
        s="$pre$rest"
    done
    printf -v _WU_SA '%s' "$s"
}

# Display width into $_WU_VL (no subshell -- use this in hot loops).
_wu_vislen_v() {
    local LC_ALL=C
    local s="$1" n=0 i _WU_ADV _WU_W _WU_SA
    _wu_strip_ansi "$s"; s=$_WU_SA
    # Fast path: plain printable ASCII is 1 column per byte.
    if [[ "$s" != *[!\ -~]* ]]; then _WU_VL=${#s}; return; fi
    # Printable ASCII is always 1 column: count it, then walk only the rest
    # (multibyte sequences stay contiguous, so clusters are still detected).
    local a=${s//[!\ -~]/}
    n=${#a}; s=${s//[\ -~]/}
    for (( i = 0; i < ${#s}; )); do
        _wuchar "$s" "$i"
        n=$(( n + _WU_W ))
        i=$(( i + _WU_ADV ))
    done
    _WU_VL=$n
}

# Display width of a string (prints it; kept for callers using $(vislen ..)).
vislen() { local _WU_VL; _wu_vislen_v "$1"; printf '%s' "$_WU_VL"; }

# Truncate $1 to at most $2 display columns into $_WU_CAP; "…" (1 column)
# is included in the budget, so the result never exceeds $2.
_wu_cap_v() {
    local s="$1" maxw="$2" _WU_VL
    _wu_vislen_v "$s"
    if (( _WU_VL <= maxw )); then _WU_CAP=$s; return; fi
    local LC_ALL=C
    local out="" n=0 i _WU_ADV _WU_W lim=$(( maxw - 1 ))
    (( lim < 0 )) && lim=0
    for (( i = 0; i < ${#s}; )); do
        _wuchar "$s" "$i"
        (( n + _WU_W > lim )) && break
        out+="${s:i:_WU_ADV}"
        n=$(( n + _WU_W ))
        i=$(( i + _WU_ADV ))
    done
    (( maxw > 0 )) && out+="…"
    _WU_CAP="${out}${RESET:-}"
}
wucap() { local _WU_CAP; _wu_cap_v "$1" "$2"; printf '%s' "$_WU_CAP"; }

# Terminal width budget for frames (COLUMNS is resolved in cli.sh).
_wu_cols() { local c=${COLUMNS:-100}; [[ "$c" =~ ^[0-9]+$ ]] || c=100; (( c < 20 )) && c=20; printf -v _WU_COLS '%d' "$c"; }

# Longest _LINES width clamped to the terminal (min 8) into $_WU_MAXW.
_wu_maxw_v() {
    local i w=0 _WU_VL _WU_COLS
    for i in ${_LINES[@]+"${_LINES[@]}"}; do
        _wu_vislen_v "$i"
        (( _WU_VL > w )) && w=$_WU_VL
    done
    _wu_cols
    (( w > _WU_COLS - 4 )) && w=$(( _WU_COLS - 4 ))
    (( w < 8 )) && w=8
    _WU_MAXW=$w
}
_wu_maxw() { local _WU_MAXW; _wu_maxw_v; printf '%s' "$_WU_MAXW"; }

pline() {
    _LINES+=( " $*" )
}

pline_sub() {
    _LINES+=( "       └─ ${DIM}$*${RESET}" )
}

# Label/value row. Stored raw (US-separated) and laid out by _wu_hw_layout
# once the whole section is known, so every label column in a box lines up
# (the old code measured labels *after* formatting and leaked widths into
# the next box).
_WU_US=$'\037'
pline_hw() {
    local emoji="${1% }"
    _LINES+=( "${_WU_US}${emoji}${_WU_US}${2}${_WU_US}${3}" )
}

_wu_hw_layout() {
    local i e lbl val rest lw=13 _WU_VL n=${#_LINES[@]} pad epad
    (( n )) || return 0
    for (( i = 0; i < n; i++ )); do
        [[ "${_LINES[i]}" == "${_WU_US}"* ]] || continue
        rest=${_LINES[i]#"$_WU_US"}; rest=${rest#*"$_WU_US"}; lbl=${rest%%"$_WU_US"*}
        _wu_vislen_v "${lbl}:"; (( _WU_VL > lw )) && lw=$_WU_VL
    done
    for (( i = 0; i < n; i++ )); do
        [[ "${_LINES[i]}" == "${_WU_US}"* ]] || continue
        rest=${_LINES[i]#"$_WU_US"}
        e=${rest%%"$_WU_US"*}; rest=${rest#*"$_WU_US"}
        lbl=${rest%%"$_WU_US"*}; val=${rest#*"$_WU_US"}
        # Icons are 1 or 2 columns wide; pad to 2 so labels start in one column.
        epad=""
        if [[ -n "$e" ]]; then _wu_vislen_v "$e"; (( _WU_VL < 2 )) && epad=" "; e="${e}${epad} "; fi
        _wu_vislen_v "${lbl}:"; printf -v pad '%*s' $(( lw - _WU_VL )) ''
        _LINES[i]="  ${e}${BOLD}${W}${lbl}:${pad}${RESET} ${val}${RESET}"
    done
}

box() {
    local icon="$1" title="$2" fn="$3" i
    icon="${icon% }"
    _LINES=()
    "$fn"
    _wu_hw_layout
    if [[ "$_WU_PLAIN" == "1" ]]; then
        printf '  %s%s\n' "${icon:+$icon }" "${BOLD}${W}${title}${RESET}"
        for i in ${_LINES[@]+"${_LINES[@]}"}; do printf '%s\n' "$i"; done
        return 0
    fi
    local _WU_MAXW _WU_VL width _iw _tw _need
    _wu_maxw_v; width=$_WU_MAXW
    # The top border must fit icon + title too, otherwise long section
    # titles get truncated and the frame turns asymmetric.
    _wu_vislen_v "$icon"; _iw=$_WU_VL
    _wu_vislen_v "$title"; _tw=$_WU_VL
    _need=$(( _iw + _tw + 7 ))
    (( width < _need )) && width=$_need
    box_top "$icon" "$title" "$width"
    for i in ${_LINES[@]+"${_LINES[@]}"}; do box_row "$i" "$width"; done
    box_bottom "$width"
}

# ┌─── icon title ─────┐   total inner width = $3 (between the corners)
box_top() {
    local icon="${1% }" title="$2" width="$3"
    local iconw titlew fill title_max rline _WU_VL _WU_CAP head
    _wu_vislen_v "$icon"; iconw=$_WU_VL
    (( iconw )) && iconw=$(( iconw + 1 ))           # "icon "
    _wu_vislen_v "$title"; titlew=$_WU_VL
    title_max=$(( width - iconw - 6 ))
    (( title_max < 3 )) && title_max=3
    if (( titlew > title_max )); then
        _wu_cap_v "$title" "$title_max"; title=$_WU_CAP; titlew=$title_max
    fi
    fill=$(( width - 5 - iconw - titlew ))
    (( fill < 1 )) && fill=1
    printf -v rline '%*s' "$fill" ''
    rline=${rline// /─}
    head="${icon:+$icon }"
    printf '  %s┌─── %s%s%s %s%s┐%s\n' "$C" "$RESET" "$head" "${BOLD}${W}${title}${RESET}" "$C" "$rline" "$RESET"
}

box_row() {
    local line="$1" width="$2" pad _WU_VL _WU_CAP
    _wu_vislen_v "$line"
    if (( _WU_VL > width )); then
        _wu_cap_v "$line" "$width"; line=$_WU_CAP; _wu_vislen_v "$line"
    fi
    printf -v pad '%*s' $(( width > _WU_VL ? width - _WU_VL : 0 )) ''
    printf '  %s│%s%s%s%s%s│%s\n' "$C" "$RESET" "$line" "$RESET" "$pad" "$C" "$RESET"
}

box_bottom() {
    local width="$1" rline
    printf -v rline '%*s' "$width" ''
    rline=${rline// /─}
    printf '  %s└%s┘%s\n' "$C" "$rline" "$RESET"
}

box_header() {
    local icon="${1% }" word="$2" title="$3"
    if [[ "$_WU_PLAIN" == "1" ]]; then
        printf '\n  %s%s%s -- %s%s\n\n' "${icon:+$icon }" "${BOLD}${W}" "$word" "$title" "${RESET}"
        return 0
    fi
    local _WU_VL _WU_CAP _WU_COLS head mid w maxw line
    head="  ${icon:+$icon  }${word} -- "
    _wu_cols; maxw=$(( _WU_COLS - 4 ))
    _wu_vislen_v "${head}${title}  "
    if (( _WU_VL > maxw )); then
        local hw; _wu_vislen_v "$head"; hw=$_WU_VL
        _wu_cap_v "$title" $(( maxw - hw - 2 > 3 ? maxw - hw - 2 : 3 )); title=$_WU_CAP
    fi
    mid="${head}${title}  "
    _wu_vislen_v "$mid"; w=$_WU_VL
    printf -v line '%*s' "$w" ''
    line=${line// /═}
    printf '\n  %s╔%s╗%s\n' "$C" "$line" "$RESET"
    printf '  %s║%s%s%s%s%s║%s\n' "$C" "$RESET" "${BOLD}${W}" "$mid" "$RESET" "$C" "$RESET"
    printf '  %s╚%s╝%s\n' "$C" "$line" "$RESET"
}

banner() {
    local i _WU_MAXW _WU_VL _WU_CAP width rline line pad
    _wu_hw_layout
    if [[ "$_WU_PLAIN" == "1" ]]; then
        for i in ${_LINES[@]+"${_LINES[@]}"}; do printf '%s\n' "$i"; done
        return 0
    fi
    _wu_maxw_v; width=$_WU_MAXW
    printf -v rline '%*s' "$width" ''
    rline=${rline// /═}
    printf '\n  %s╔%s╗%s\n' "$C" "$rline" "$RESET"
    for i in ${_LINES[@]+"${_LINES[@]}"}; do
        line="$i"
        _wu_vislen_v "$line"
        if (( _WU_VL > width )); then _wu_cap_v "$line" "$width"; line=$_WU_CAP; _wu_vislen_v "$line"; fi
        printf -v pad '%*s' $(( width > _WU_VL ? width - _WU_VL : 0 )) ''
        printf '  %s║%s%s%s%s%s║%s\n' "$C" "$RESET" "$line" "$RESET" "$pad" "$C" "$RESET"
    done
    printf '  %s╚%s╝%s\n' "$C" "$rline" "$RESET"
}

# ─── Re-frame hand-drawn output ──────────────────────────────────
# Tools with _WU_MANUAL=1 (wellusb/wellpci/wellmod/wellblock) print their own
# "╔═╗ ║ ╚═╝" headers and "┌─── title / │ row / └──┘" sections with fixed
# widths. This pass re-measures every block with real display widths, adds
# the missing right-hand borders, closes blocks that were left open and
# drops orphan bottoms -- so frames are always straight, whatever the text.
_wu_reframe() {
    local line strip kind="" _WU_VL _WU_CAP _WU_SA _WU_COLS maxw
    local -a blk=() ; local btitle="" bw=0 i pad rline
    _wu_cols; maxw=$(( _WU_COLS - 4 ))
    local gw=0     # one width for every section -> a tidy column of boxes
    _wu_rf_flush() {
        [[ -n "$kind" ]] || return 0
        local w=$bw
        [[ "$kind" == sec ]] && (( gw > w )) && w=$gw
        (( w > maxw )) && w=$maxw
        if [[ "$kind" == hdr ]]; then
            printf -v rline '%*s' "$w" ''; rline=${rline// /═}
            printf '  %s╔%s╗%s\n' "$C" "$rline" "$RESET"
            for i in ${blk[@]+"${blk[@]}"}; do
                _wu_vislen_v "$i"; if (( _WU_VL > w )); then _wu_cap_v "$i" "$w"; i=$_WU_CAP; _wu_vislen_v "$i"; fi
                printf -v pad '%*s' $(( w - _WU_VL )) ''
                printf '  %s║%s%s%s%s%s║%s\n' "$C" "$RESET" "$i" "$RESET" "$pad" "$C" "$RESET"
            done
            printf '  %s╚%s╝%s\n' "$C" "$rline" "$RESET"
        else
            local tw fill
            _wu_vislen_v "$btitle"; tw=$_WU_VL
            if (( 4 + tw + 2 > w )); then _wu_cap_v "$btitle" $(( w - 6 > 3 ? w - 6 : 3 )); btitle=$_WU_CAP; _wu_vislen_v "$btitle"; tw=$_WU_VL; fi
            fill=$(( w - 4 - tw )); (( fill < 1 )) && fill=1
            printf -v rline '%*s' "$fill" ''; rline=${rline// /─}
            printf '  %s┌───%s%s%s %s┐%s\n' "$C" "$RESET" "$btitle" "$RESET" "$C$rline" "$RESET"
            for i in ${blk[@]+"${blk[@]}"}; do
                _wu_vislen_v "$i"; if (( _WU_VL > w )); then _wu_cap_v "$i" "$w"; i=$_WU_CAP; _wu_vislen_v "$i"; fi
                printf -v pad '%*s' $(( w - _WU_VL )) ''
                printf '  %s│%s%s%s%s%s│%s\n' "$C" "$RESET" "$i" "$RESET" "$pad" "$C" "$RESET"
            done
            printf -v rline '%*s' "$w" ''; rline=${rline// /─}
            printf '  %s└%s┘%s\n' "$C" "$rline" "$RESET"
        fi
        kind=""; blk=(); btitle=""; bw=0
    }
    _wu_rf_trim() {   # strip trailing spaces / SGR codes / a closing border
        local s="$1" prev=""
        while [[ "$s" != "$prev" ]]; do
            prev=$s
            s=${s%"${s##*[! ]}"}
            [[ "$s" == *$'\033['*m ]] && [[ "${s##*$'\033['}" =~ ^[0-9\;]*m$ ]] && s=${s%$'\033['*}
            s=${s%[│║]}
        done
        printf -v _WU_SA '%s' "$s"
    }
    # pass 1: widest section row / title
    while IFS= read -r line || [[ -n "$line" ]]; do
        case "$line" in
            *"  ┌───"*) _wu_strip_ansi "$line"; _wu_rf_trim "${_WU_SA#*┌───}"; _wu_vislen_v "$_WU_SA"; (( _WU_VL + 7 > gw )) && gw=$(( _WU_VL + 7 )) ;;
            *"  │"*)    _wu_strip_ansi "$line"; [[ "$_WU_SA" == "  │"* ]] || continue
                        _wu_rf_trim "${_WU_SA#*│}"; _wu_vislen_v "$_WU_SA"; (( _WU_VL > gw )) && gw=$_WU_VL ;;
        esac
    done <<< "$1"
    (( gw > maxw )) && gw=$maxw
    while IFS= read -r line || [[ -n "$line" ]]; do
        _wu_strip_ansi "$line"; strip=$_WU_SA
        case "$strip" in
            "  ╔"*) _wu_rf_flush; kind=hdr ;;
            "  ║"*)
                [[ "$kind" == hdr ]] || { _wu_rf_flush; kind=hdr; }
                _wu_rf_trim "${line#*║}"; line="$_WU_SA  "
                blk+=( "$line" ); _wu_vislen_v "$line"; (( _WU_VL > bw )) && bw=$_WU_VL ;;
            "  ╚"*) _wu_rf_flush ;;
            "  ┌"*)
                _wu_rf_flush; kind=sec
                _wu_rf_trim "${line#*┌───}"; btitle=$_WU_SA
                _wu_vislen_v "$btitle"; bw=$(( _WU_VL + 7 )) ;;
            "  │"*)
                if [[ "$kind" != sec ]]; then _wu_rf_flush; printf '  %s\n' "${line#*│}"; continue; fi
                _wu_rf_trim "${line#*│}"; line=$_WU_SA
                blk+=( "$line" ); _wu_vislen_v "$line"; (( _WU_VL > bw )) && bw=$_WU_VL ;;
            "  └"*) _wu_rf_flush ;;   # recomputed bottom (orphans are dropped)
            *) _wu_rf_flush; printf '%s\n' "$line" ;;
        esac
    done <<< "$1"
    _wu_rf_flush
    unset -f _wu_rf_flush _wu_rf_trim
}
