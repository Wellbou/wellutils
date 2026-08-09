# cli.sh — shared CLI parsing + output policy for wellutils tools
# Part of wellutils by wellbou_
# Source AFTER lang.sh and box.sh (or after the tool's own color defs).
#
# The tool must define before sourcing:
#   _WU_TOOLNAME  (e.g. "wellusb")
#   _WU_NAME      (display name, e.g. "WellUSB")
#   _WU_VERSION   (e.g. "2.0")
#   _WU_TAGLINE   (one-line description for --help)
# and optionally:
#   _WU_EXTRA_HELP (extra --help lines, verbatim)
#   _WU_MANUAL=1   for tools that hand-draw box frames (wellusb, wellpci,
#                  wellblock, wellmod): --plain strips the frames via
#                  _wu_plainify instead of native box() support.
# The tool then calls:  wu_run main "$@"
# Language/color/emoji flags are honoured; WELLUTILS_LANG is exported for t().

# bash 3.2-compatible lowercase (no ${var,,}; tr is in busybox/base too)
_wlc() { printf '%s' "$1" | tr '[:upper:]' '[:lower:]'; }

_WU_MODE="" _WU_COLOR="auto" _WU_EMOJI="auto" _WU_DEBUG="" _WU_LANG_ARG=""
_WU_MANUAL=${_WU_MANUAL:-0}
_WU_TOOLNAME=${_WU_TOOLNAME:-${_WU_NAME:-tool}}
_WU_EXTRA_HELP=${_WU_EXTRA_HELP:-}
_WU_EXTRA_PARSE=${_WU_EXTRA_PARSE:-}
_WU_EXTRA_CONSUMED=0

wu_usage() {
    cat <<EOF
Usage: ${_WU_TOOLNAME} [options]

${_WU_TAGLINE}

Options:
  -h, --help                 show this help
  -V, --version              show version
      --lang ru|en|auto      output language (auto = from locale)
      --color always|auto|never   colorize output (auto = tty)
      --plain                plain text, no box drawing
      --box                  force box drawing even when piped
      --no-emoji             drop emoji icons
      --debug                shell tracing
${_WU_EXTRA_HELP}
Exit codes: 0 ok, 2 bad CLI, 3 runtime error.
EOF
}

wu_parse() {
    while (( $# > 0 )); do
        case "$1" in
            -h|--help) wu_usage; exit 0 ;;
            -V|--version) printf '%s %s\n' "$_WU_NAME" "$_WU_VERSION"; exit 0 ;;
            --lang)
                [[ $# -ge 2 ]] || { printf '%s: --lang needs ru|en|auto\n' "$_WU_TOOLNAME" >&2; exit 2; }
                _WU_LANG_ARG="$2"; shift 2 ;;
            --lang=*) _WU_LANG_ARG="${1#*=}"; shift ;;
            --color)
                [[ $# -ge 2 ]] || { printf '%s: --color needs always|auto|never\n' "$_WU_TOOLNAME" >&2; exit 2; }
                _WU_COLOR="$2"; shift 2 ;;
            --color=*) _WU_COLOR="${1#*=}"; shift ;;
            --plain) _WU_MODE="plain"; shift ;;
            --box) _WU_MODE="box"; shift ;;
            --no-emoji) _WU_EMOJI="no"; shift ;;
            --emoji)    _WU_EMOJI="auto"; shift ;;
            --debug)  _WU_DEBUG=1; shift ;;
            -*) if [[ -n "$_WU_EXTRA_PARSE" ]] && $_WU_EXTRA_PARSE "$@"; then
                    shift "${_WU_EXTRA_CONSUMED:-0}"
                else
                    printf '%s: unknown option %s\n' "$_WU_TOOLNAME" "$1" >&2; wu_usage >&2; exit 2
                fi ;;
            *)  if [[ -n "$_WU_EXTRA_PARSE" ]] && $_WU_EXTRA_PARSE "$@"; then
                    shift "${_WU_EXTRA_CONSUMED:-0}"
                else
                    printf '%s: unexpected argument %s\n' "$_WU_TOOLNAME" "$1" >&2; wu_usage >&2; exit 2
                fi ;;
        esac
    done

    case "$(_wlc "$_WU_COLOR")" in
        always|auto|never) : ;;
        *) printf '%s: --color must be always|auto|never\n' "$_WU_TOOLNAME" >&2; exit 2 ;;
    esac
    case "$(_wlc "$_WU_LANG_ARG")" in
        ""|ru|en|auto) : ;;
        *) printf '%s: --lang must be ru|en|auto\n' "$_WU_TOOLNAME" >&2; exit 2 ;;
    esac

    case "$(_wlc "$_WU_LANG_ARG")" in
        ru) WELLUTILS_LANG=RU ;;
        en) WELLUTILS_LANG=EN ;;
        auto)
            case "$(printf '%s' "${LC_ALL:-${LC_MESSAGES:-${LANG:-}}}" | tr '[:upper:]' '[:lower:]')" in
                ru*) WELLUTILS_LANG=RU ;;
            esac ;;
    esac

    [[ "$_WU_DEBUG" == "1" ]] && set -x
    return 0
}

wu_run() {
    local fn="$1"; shift
    wu_parse "$@"

    if [[ -t 1 ]]; then _WU_TTY=1; else _WU_TTY=0; fi
    if [[ -z "$_WU_MODE" ]]; then
        if [[ $_WU_TTY -eq 0 ]]; then _WU_MODE="plain"; else _WU_MODE="box"; fi
    fi
    [[ "$_WU_MODE" == "plain" ]] && _WU_PLAIN=1 || _WU_PLAIN=0

    case "$_WU_COLOR" in
        always) _WU_COLOR_ON=1 ;;
        never)  _WU_COLOR_ON=0 ;;
        *)
            if [[ $_WU_TTY -eq 1 && -z "${NO_COLOR:-}" && "${TERM:-}" != "dumb" && "$_WU_MODE" != "plain" ]]; then
                _WU_COLOR_ON=1
            else
                _WU_COLOR_ON=0
            fi ;;
    esac

    if [[ "$_WU_EMOJI" == "auto" ]]; then
        case "${LC_ALL:-${LANG:-}}" in
            C*|POSIX) _WU_EMOJI="no" ;;
            *) [[ "${TERM:-}" == "dumb" ]] && _WU_EMOJI="no" || _WU_EMOJI="yes" ;;
        esac
    fi

    if [[ $_WU_COLOR_ON -eq 0 ]]; then
        R= G= Y= B= M= C= W= DIM= BOLD= RESET=
        ORANGE= RED_BG=
    fi

    if [[ "$_WU_MANUAL" == "1" && "$_WU_PLAIN" == "1" ]]; then
        local out
        out=$("$fn" 2>&1)
        _wu_plainify "$out"
    else
        "$fn"
    fi
}

_emu() { [[ "$_WU_EMOJI" == "yes" ]] && printf '%s' "$1"; return 0; }
_ic()  { [[ "$_WU_EMOJI" == "yes" ]] && printf '%s ' "$1"; return 0; }

# Strip hand-drawn box frames from output (byte-safe, locale-independent).
# Covers U+2500-U+257F (box drawing) plus tab compaction.
# Built in a single fork-free loop (was 256 subshells per launch).
_WU_BOXCHARS=()
for (( _cp=0x2500; _cp<=0x257F; _cp++ )); do
    _b1=$((0xE0 | (_cp >> 12)))
    _b2=$((0x80 | ((_cp >> 6) & 0x3F)))
    _b3=$((0x80 | (_cp & 0x3F)))
    _wi=$(( _cp - 0x2500 ))
    printf -v _oc '\\%03o\\%03o\\%03o' "$_b1" "$_b2" "$_b3"
    printf -v '_WU_BOXCHARS[_wi]' '%b' "$_oc"
done
unset _cp _b1 _b2 _b3 _oc _wi
_wu_plainify() {
    local line out="" c
    while IFS= read -r line; do
        for c in "${_WU_BOXCHARS[@]}"; do
            line=${line//"$c"/ }
        done
        line=${line//$'\t'/ }
        out+="$line"$'\n'
    done <<< "$1"
    printf '%s' "$out" | sed -e 's/  */ /g' -e 's/ $//' -e 's/^ /  /'
}