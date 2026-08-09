# box.sh — shared adaptive box-drawing engine for wellutils
# Part of wellutils by wellbou_
# Depends on: lang.sh (source it first — provides t())

# ─── Colors & Symbols ───────────────────────────────────────────
R=$'\033[1;31m'  G=$'\033[1;32m'  Y=$'\033[1;33m'  B=$'\033[1;34m'
M=$'\033[1;35m'  C=$'\033[1;36m'  W=$'\033[1;37m'  DIM=$'\033[2m'
BOLD=$'\033[1m'  RESET=$'\033[0m'

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
    local c b b2 b3 cp j
    c="${s:i:1}"
    printf -v b '%d' "'$c"
    if (( b < 0x80 )); then
        if [[ "$c" == $'\x1b' ]]; then
            j=$(( i + 1 ))
            while (( j < ${#s} )); do
                [[ "${s:j:1}" == "m" ]] && break
                j=$(( j + 1 ))
            done
            _WU_ADV=$(( j - i + 1 )); _WU_W=0
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
    for i in "${_LINES[@]}"; do
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
    pad_l=$(_wu_pad_r "${label}:" 13)
    _LINES+=( "  ${emoji} ${BOLD}${W}${pad_l}${RESET} ${value}${RESET}" )
}

box() {
    local icon="$1" title="$2" fn="$3"
    icon="${icon% }"
    _LINES=()
    "$fn"
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
        printf '\n  %s%s %s — %s%s\n\n' "$icon" "${BOLD}${W}" "$word" "$title" "${RESET}"
        return 0
    fi
    local inner
    inner=$(( $(vislen "$icon") + $(vislen "$word") + $(vislen "$title") + 6 ))
    (( inner > ${COLUMNS:-100} - 6 )) && inner=$(( ${COLUMNS:-100} - 6 ))
    local line
    printf -v line '%*s' "$inner" ''
    line=${line// /═}
    printf '\n  %s╔═%s═╗%s\n' "$C" "$line" "$RESET"
    printf '  %s║%s%s  %s  %s — %s  %s%s║%s\n' "$C" "$RESET" "${BOLD}${W}" "$icon" "$word" "$title" "$RESET" "$C" "$RESET"
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
