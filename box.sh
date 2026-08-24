# box.sh -- shared adaptive box-drawing engine for wellutils
# Part of wellutils by wellbou_
# Depends on: lang.sh (source it first -- provides t())

# ─── Colors & Symbols ───────────────────────────────────────────
R=$'\033[1;31m'  G=$'\033[1;32m'  Y=$'\033[1;33m'  B=$'\033[1;34m'
M=$'\033[1;35m'  C=$'\033[1;36m'  W=$'\033[1;37m'  DIM=$'\033[2m'
BOLD=$'\033[1m'  RESET=$'\033[0m'

# ─── ASCII fallbacks for Unicode block elements ─────────────
# Usage: wu_bar FILLED EMPTY  -- prints a progress bar using Unicode or ASCII.
wu_bar() {
    local filled="${1:-0}" empty="${2:-0}" i
    if [[ "${_WU_UNICODE:-1}" -eq 1 ]]; then
        for (( i=0; i<filled; i++ )); do printf '█'; done
        for (( i=0; i<empty; i++ )); do printf '░'; done
    else
        for (( i=0; i<filled; i++ )); do printf '#'; done
        for (( i=0; i<empty; i++ )); do printf '.'; done
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
    [[ "$bus" == 0000:* ]] || bus="0000:${bus}"
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

# ─── PCI slot device filter ──────────────────────────────────────
# Populates global arrays: _PCI_BUS[], _PCI_CLASS[], _PCI_DESC[]
# Shows expansion card class devices only, filtering out chipset.
pci_slot_devices() {
    _PCI_BUS=() _PCI_CLASS=() _PCI_DESC=()
    local d addr bus major class_hex
    for d in /sys/bus/pci/devices/*/; do
        [[ -d "$d" ]] || continue
        addr=$(basename "$d")
        bus=$(echo "$addr" | cut -d: -f2 | cut -d. -f1)
        class_hex=$(cat "$d/class" 2>/dev/null) || continue
        class_hex="${class_hex#0x}"
        major="${class_hex:0:2}"
        local sub="${class_hex:2:2}"

        # always skip bridges (host, PCI-to-PCI, PCI-to-ISA)
        [[ "$major" == "06" ]] && continue

        # always skip: Memory, Processor, SMBus, Serial
        [[ "$major" == "05" || "$major" == "0b" ]] && continue
        [[ "$major" == "0c" && "$sub" == "05" ]] && continue   # SMBus
        [[ "$major" == "0c" && "$sub" == "00" ]] && continue   # Serial

        # always show: Display(03xx), Wireless(0dxx)
        if [[ "$major" == "03" || "$major" == "0d" ]]; then
            local desc
            desc=$(lspci -s "$addr" 2>/dev/null | sed 's/^[0-9a-f:.]* //')
            _PCI_BUS+=("$addr")
            _PCI_CLASS+=("$class_hex")
            _PCI_DESC+=("$desc")
            continue
        fi

        # always show: RAID(0104), NVMe(0108)
        if [[ "$major" == "01" && ( "$sub" == "04" || "$sub" == "08" ) ]]; then
            local desc
            desc=$(lspci -s "$addr" 2>/dev/null | sed 's/^[0-9a-f:.]* //')
            _PCI_BUS+=("$addr")
            _PCI_CLASS+=("$class_hex")
            _PCI_DESC+=("$desc")
            continue
        fi

        # bus 00: hide all remaining chipset classes
        if [[ "$bus" == "00" ]]; then
            continue
        fi

        # bus >00: hide embedded classes (storage, ethernet, USB, comm)
        # but show audio(04) on bus >00 -- it's often GPU HDMI audio or standalone sound card
        case "$major" in
            01|02|07) continue ;;   # storage, network, comm
        esac
        [[ "$major" == "0c" ]] && continue   # serial bus (USB etc.)

        # catch-all: show the device
        local desc
        desc=$(lspci -s "$addr" 2>/dev/null | sed 's/^[0-9a-f:.]* //')
        _PCI_BUS+=("$addr")
        _PCI_CLASS+=("$class_hex")
        _PCI_DESC+=("$desc")
    done
}

# ─── Adaptive box engine ────────────────────────────────────────
# Every section is a rounded-corner box whose width always fits the
# longest content line (long strings no longer overflow the frame).
_LINES=()
# Set _WU_PLAIN=1 to render sections without box drawing (plain text).
_WU_PLAIN=${_WU_PLAIN:-0}

# Classify one character at index $2 of string $1.
# Writes the bytes-to-advance and display width to $_WU_ADV and $_WU_W.
# Display width: ASCII=1, 2-byte=1 (combining/accent prefixes=0), 3-byte=1
# (CJK/wide=2, combining/VS16/emoji-prefix=0/2), 4-byte=2. ANSI escapes
# are skipped whole with width 0. Byte-level (works under any locale).
_wuchar() {
    local s="$1" i="$2"
    local c b b2 b3 cp=0 j
    c="${s:i:1}"
    printf -v b '%d' "'$c"
    if (( b < 0x80 )); then
        if [[ "$c" == $'\x1b' ]]; then
            j=$(( i + 1 ))
            while (( j < ${#s} )); do
                [[ "${s:j:1}" == "m" ]] && break
                j=$(( j + 1 ))
            done
            if (( j < ${#s} )); then
                _WU_ADV=$(( j - i + 1 )); _WU_W=0
            else
                _WU_ADV=1; _WU_W=0
            fi
        else
            _WU_ADV=1; _WU_W=1
        fi
    elif (( b < 0xc0 )); then
        _WU_ADV=1; _WU_W=0
    elif (( b < 0xe0 )); then
        if (( b < 0xcc || b >= 0xd0 )); then _WU_W=1; else _WU_W=0; fi
        _WU_ADV=2
    elif (( b < 0xf0 )); then
        if [[ "${s:i+3:3}" == $'\xEF\xB8\x8F' ]]; then
            _WU_ADV=3; _WU_W=2
        elif [[ "${s:i:3}" == $'\xEF\xB8\x8F' ]]; then
            _WU_ADV=3; _WU_W=0
        else
            printf -v b2 '%d' "'${s:i+1:1}"
            printf -v b3 '%d' "'${s:i+2:1}"
            cp=$(( ((b & 0x0f) << 12) | ((b2 & 0x3f) << 6) | (b3 & 0x3f) ))
            if (( cp >= 0x300 && cp <= 0x36f || cp >= 0x1ab0 && cp <= 0x1aff || cp >= 0x1dc0 && cp <= 0x1dff || cp >= 0x20d0 && cp <= 0x20ff || cp >= 0xfe20 && cp <= 0xfe2f )); then
                _WU_ADV=3; _WU_W=0
            elif (( cp >= 0x1100 && cp <= 0x115f || cp >= 0x2e80 && cp <= 0xa4cf || cp >= 0xac00 && cp <= 0xd7a3 || cp >= 0xf900 && cp <= 0xfaff || cp >= 0xfe30 && cp <= 0xfe6f || cp >= 0xff00 && cp <= 0xff60 || cp >= 0xffe0 && cp <= 0xffe6 )); then
                _WU_ADV=3; _WU_W=2
            else
                _WU_ADV=3; _WU_W=1
            fi
        fi
    else
        _WU_ADV=4; _WU_W=2
    fi
    # Regional indicator pairs (flags): if this is a regional indicator (U+1F1E6..U+1F1FF)
    # and the next char is also a regional indicator, collapse the pair to width 2.
    if (( cp >= 0x1F1E6 && cp <= 0x1F1FF && i + 4 < ${#s} )); then
        local cp2=0
        if [[ "${s:i+4:1}" == $'\xF0' && "${s:i+5:1}" == $'\x9F' ]]; then
            printf -v b2 '%d' "'${s:i+6:1}"; printf -v b3 '%d' "'${s:i+7:1}"
            printf -v b4 '%d' "'${s:i+8:1}"
            cp2=$(( ((b2 & 0x0f) << 12) | ((b3 & 0x3f) << 6) | (b4 & 0x3f) ))
        fi
        if (( cp2 >= 0x1F1E6 && cp2 <= 0x1F1FF )); then
            _WU_ADV=8; _WU_W=2
            return
        fi
    fi
    # ZWJ sequences: if U+200D follows, skip the entire chain and count as width 2.
    if (( i + 4 < ${#s} )); then
        local zwj_check="${s:i+4:3}"
        if [[ "$zwj_check" == $'\xE2\x80\x8D' ]]; then
            _WU_ADV=4; _WU_W=0
            local j=$(( i + 7 ))
            while (( j + 3 < ${#s} )); do
                local next3="${s:j:3}"
                if [[ "$next3" == $'\xE2\x80\x8D' ]]; then
                    j=$(( j + 3 ))
                elif [[ "${s:j:1}" == $'\xF0' ]]; then
                    j=$(( j + 4 ))
                else
                    break
                fi
            done
            _WU_ADV=$(( j - i )); _WU_W=2
            return
        fi
    fi
}

# Display width of a string (fork-free, real wcwidth semantics).
vislen() {
    local LC_ALL=C
    local s="$1" n=0 i _WU_ADV _WU_W
    for (( i = 0; i < ${#s}; )); do
        _wuchar "$s" "$i"
        n=$(( n + _WU_W ))
        i=$(( i + _WU_ADV ))
    done
    printf '%s' "$n"
}

# Truncate $1 to at most $2 display columns, appending "…" when cut.
wucap() {
    local LC_ALL=C
    local s="$1" maxw="$2" out="" n=0 i _WU_ADV _WU_W
    for (( i = 0; i < ${#s}; )); do
        _wuchar "$s" "$i"
        if (( n + _WU_W > maxw )); then
            out+="…${RESET}"
            break
        fi
        out+="${s:i:_WU_ADV}"
        n=$(( n + _WU_W ))
        i=$(( i + _WU_ADV ))
    done
    printf '%s' "$out"
}

# Longest _LINES width clamped to the terminal (min 8, fallback 100).
_wu_maxw() {
    local v i w=0
    for i in "${_LINES[@]+"${_LINES[@]}"}"; do
        v=$(vislen "$i")
        (( v > w )) && w=$v
    done
    (( w > ${COLUMNS:-100} - 4 )) && w=$(( ${COLUMNS:-100} - 4 ))
    (( w < 8 )) && w=8
    printf '%s' "$w"
}

pline() {
    _LINES+=( " $*" )
}

pline_sub() {
    _LINES+=( "       └─ ${DIM}$*${RESET}" )
}

pline_hw() {
    local emoji="$1" label="$2" value="$3" pad_l
    emoji="${emoji% }"
    if [[ -z "${_HW_LABEL_W:-}" ]]; then
        pad_l=$(_wu_pad_r "${label}:" 13)
    else
        pad_l=$(_wu_pad_r "${label}:" "$_HW_LABEL_W")
    fi
    _LINES+=( "  ${emoji} ${BOLD}${W}${pad_l}${RESET} ${value}${RESET}" )
}

box() {
    local icon="$1" title="$2" fn="$3"
    icon="${icon% }"
    _LINES=()
    "$fn"
    # Auto-size pline_hw label column: find max label width across hw lines.
    _HW_LABEL_W=13
    local _tmp _lbl _lw
    for _tmp in "${_LINES[@]+"${_LINES[@]}"}"; do
        case "$_tmp" in
            *${W}${pad_l:-}*${RESET}*|*${W}*)
                # Extract label between BOLD+W and RESET, strip trailing ":"
                _lbl="${_tmp#*${BOLD}${W}}"
                _lbl="${_lbl%%${RESET}*}"
                _lbl="${_lbl%:}"
                _lbl="${_lbl%% }"
                [[ -n "$_lbl" ]] || continue
                _lw=$(vislen "$_lbl")
                (( _lw > _HW_LABEL_W )) && _HW_LABEL_W=$_lw ;;
        esac
    done
    if [[ "$_WU_PLAIN" == "1" ]]; then
        printf '  %s %s%s\n' "$icon" "${BOLD}${W}${title}${RESET}"
        for i in "${_LINES[@]}"; do printf '%s\n' "$i"; done
        return 0
    fi
    local width
    width=$(_wu_maxw)
    box_top "$icon" "$title" "$width"
    for i in "${_LINES[@]}"; do box_row "$i" "$width"; done
    box_bottom "$width"
}

box_top() {
    local icon="$1" title="$2" width="$3"
    icon="${icon% }"
    local iconw titlew fill title_max
    iconw=$(vislen "$icon")
    titlew=$(vislen "$title")
    title_max=$(( width - iconw - 7 ))
    (( title_max < 3 )) && title_max=3
    if (( titlew > title_max )); then
        titlew=$title_max
        title=$(wucap "$title" "$title_max")
    fi
    fill=$(( width - iconw - titlew - 5 ))
    (( fill < 1 )) && fill=1
    local rline
    printf -v rline '%*s' "$fill" ''
    rline=${rline// /─}
    printf '  %s┌─── %s%s %s%s┐%s\n' "$C" "$RESET" "$icon" "${BOLD}${W}${title}${RESET}" "$C$rline" "$RESET"
}

box_row() {
    local line="$1" width="$2"
    local pad
    if (( $(vislen "$line") > width )); then
        line=$(wucap "$line" "$width")
    fi
    pad=$(( width - $(vislen "$line") ))
    (( pad < 0 )) && pad=0
    printf '  %s│%s%s%s%s│%s\n' "$C" "$RESET" "$line" "$(printf '%*s' "$pad" '')" "$C" "$RESET"
}

box_bottom() {
    local width="$1" rline
    printf -v rline '%*s' "$width" ''
    rline=${rline// /─}
    printf '  %s└%s┘%s\n' "$C" "$rline" "$RESET"
}

box_header() {
    local icon="$1" word="$2" title="$3"
    if [[ "$_WU_PLAIN" == "1" ]]; then
        printf '\n  %s%s %s -- %s%s\n\n' "$icon" "${BOLD}${W}" "$word" "$title" "${RESET}"
        return 0
    fi
    local inner maxw iconw wordw titlew tmax
    # Middle row spans icon + "  " + word + " -- " + title + "  " between the
    # two ║ = width+9; border rows span "═" + fill + "═" between corners, so
    # fill must be width+7 (width = iconw+wordw+titlew) to match exactly.
    maxw=$(( ${COLUMNS:-100} - 6 ))
    (( maxw < 8 )) && maxw=8
    iconw=$(vislen "$icon"); wordw=$(vislen "$word"); titlew=$(vislen "$title")
    if (( iconw + wordw + titlew + 7 > maxw )); then
        tmax=$(( maxw - iconw - wordw - 7 ))
        (( tmax < 3 )) && tmax=3
        title=$(wucap "$title" "$tmax")
        titlew=$(vislen "$title")
    fi
    inner=$(( iconw + wordw + titlew + 7 ))
    local line
    printf -v line '%*s' "$inner" ''
    line=${line// /═}
    printf '\n  %s╔═%s═╗%s\n' "$C" "$line" "$RESET"
    printf '  %s║%s%s  %s  %s -- %s  %s%s║%s\n' "$C" "$RESET" "${BOLD}${W}" "$icon" "$word" "$title" "$RESET" "$C" "$RESET"
    printf '  %s╚═%s═╝%s\n' "$C" "$line" "$RESET"
}

banner() {
    local width v i
    width=$(_wu_maxw)
    if [[ "$_WU_PLAIN" == "1" ]]; then
        for i in "${_LINES[@]}"; do printf '%s\n' "$i"; done
        return 0
    fi
    local rline
    printf -v rline '%*s' "$width" ''
    rline=${rline// /═}
    printf '\n  %s╔%s╗%s\n' "$C" "$rline" "$RESET"
    for i in "${_LINES[@]}"; do
        local line="$i" pad
        if (( $(vislen "$line") > width )); then
            line=$(wucap "$line" "$width")
        fi
        pad=$(( width - $(vislen "$line") ))
        (( pad < 0 )) && pad=0
        printf '  %s║%s%s%s%s║%s\n' "$C" "$RESET" "$line" "$(printf '%*s' "$pad" '')" "$C" "$RESET"
    done
    printf '  %s╚%s╝%s\n' "$C" "$rline" "$RESET"
}
