# cli.sh -- shared CLI parsing + output policy for wellutils tools
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
_WU_JSON=0
_WU_SHORT=0
_WU_HTML=0
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
      --emoji                force emoji icons
      --json                 machine-readable JSON
      --short                one-line compact status (status bars)
      --html                 standalone HTML report page
      --debug                shell tracing
${_WU_EXTRA_HELP}
Exit codes: 0 ok, 2 bad CLI, 3 runtime error.
EOF
}

# Locale-based language auto-detect (with system locale file fallback for
# sudo/root where LANG is usually empty or C).
# _wu_detect_lang is provided by lang.sh (sourced before cli.sh)

wu_parse() {
    while (( $# > 0 )); do
        case "$1" in
            -h|--help) wu_usage; exit 0 ;;
            -V|--version) printf '%s %s\n' "$_WU_NAME" "$_WU_VERSION"; exit 0 ;;
            -l|--lang)
                [[ $# -ge 2 ]] || { printf '%s: --lang needs ru|en|auto\n' "$_WU_TOOLNAME" >&2; exit 2; }
                _WU_LANG_ARG="$2"; shift 2 ;;
            --lang=*) _WU_LANG_ARG="${1#*=}"; shift ;;
            --color)
                [[ $# -ge 2 ]] || { printf '%s: --color needs always|auto|never\n' "$_WU_TOOLNAME" >&2; exit 2; }
                _WU_COLOR="$2"; shift 2 ;;
            --color=*) _WU_COLOR="${1#*=}"; shift ;;
            --plain) _WU_MODE="plain"; _WU_MODE_WAS_SET=1; shift ;;
            --box) _WU_MODE="box"; _WU_MODE_WAS_SET=1; shift ;;
            --no-emoji) _WU_EMOJI="no"; shift ;;
            --emoji)    _WU_EMOJI="yes"; shift ;;
            --json)   _WU_JSON=1; shift ;;
            --short)  _WU_SHORT=1; shift ;;
            --html)   _WU_HTML=1; shift ;;
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
        always|auto|never) _WU_COLOR="$(_wlc "$_WU_COLOR")" ;;
        *) printf '%s: --color must be always|auto|never\n' "$_WU_TOOLNAME" >&2; exit 2 ;;
    esac
    case "$(_wlc "$_WU_LANG_ARG")" in
        ""|ru|en|auto) : ;;
        *) printf '%s: --lang must be ru|en|auto\n' "$_WU_TOOLNAME" >&2; exit 2 ;;
    esac

    local _out_modes=0
    (( _WU_JSON )) && _out_modes=$(( _out_modes + 1 ))
    (( _WU_SHORT )) && _out_modes=$(( _out_modes + 1 ))
    (( _WU_HTML )) && _out_modes=$(( _out_modes + 1 ))
    (( _out_modes > 1 )) && { printf '%s: --json, --short and --html are mutually exclusive\n' "$_WU_TOOLNAME" >&2; exit 2; }
    # --short is opt-in per tool: status-bar tools set _WU_SHORT_OK=1.
    if (( _WU_SHORT )) && [[ "${_WU_SHORT_OK:-0}" != "1" ]]; then
        printf '%s: --short is not supported by this tool\n' "$_WU_TOOLNAME" >&2
        exit 2
    fi

    case "$(_wlc "$_WU_LANG_ARG")" in
        ru) WELLUTILS_LANG=RU ;;
        en) WELLUTILS_LANG=EN ;;
        auto) _wu_detect_lang ;;
        "") : ;;
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

    # Detect Unicode box-drawing support. Terminals that lack it get
    # plain mode automatically (ASCII boxes look worse than no boxes).
    _WU_UNICODE=1
    case "${LC_ALL:-${LANG:-}}" in
        C*|POSIX) _WU_UNICODE=0 ;;
    esac
    [[ "${TERM:-}" == "dumb" ]] && _WU_UNICODE=0
    # If Unicode unavailable and user didn't explicitly request box mode, force plain.
    if [[ $_WU_UNICODE -eq 0 && "$_WU_PLAIN" -eq 0 && -z "${_WU_MODE_WAS_SET:-}" ]]; then
        _WU_PLAIN=1
        _WU_MODE="plain"
    fi

    if [[ "$_WU_HTML" == "1" ]]; then
        # HTML report: force box rendering + colors, capture, convert ANSI.
        _WU_PLAIN=0 _WU_MODE="box" _WU_COLOR_ON=1 _WU_EMOJI="yes"
        R=$'\033[1;31m' G=$'\033[1;32m' Y=$'\033[1;33m' B=$'\033[1;34m'
        M=$'\033[1;35m' C=$'\033[1;36m' W=$'\033[1;37m' DIM=$'\033[2m'
        BOLD=$'\033[1m' RESET=$'\033[0m' ORANGE=$'\033[1;38;5;208m' RED_BG=""
        local out _fn_rc=0
        out=$("$fn") || _fn_rc=$?
        wu_html_page "$out"
        return "$_fn_rc"
    fi

    if [[ $_WU_COLOR_ON -eq 0 ]]; then
        R= G= Y= B= M= C= W= DIM= BOLD= RESET=
        ORANGE= RED_BG=
    fi

    if [[ "$_WU_MANUAL" == "1" && "$_WU_PLAIN" == "1" && "$_WU_JSON" != "1" ]]; then
        local out _fn_rc=0
        out=$("$fn") || _fn_rc=$?
        _wu_plainify "$out"
        return "$_fn_rc"
    else
        "$fn"
    fi
}

# ─── HTML export (deterministic ANSI -> span conversion) ──────────
_wu_html_esc() {
    local s="$1"
    s=${s//&/\&amp;}
    s=${s//</\&lt;}
    s=${s//>/\&gt;}
    printf '%s' "$s"
}

# Convert wellutils ANSI output to an HTML fragment. Only the SGR codes the
# suite emits are mapped (fixed palette), everything else passes through.
wu_ansi_to_html() {
    local esc
    esc=$(printf '\033')
    LC_ALL=C awk -v esc="$esc" '
    function hesc(s) {
        gsub(/&/, "\\&amp;", s); gsub(/</, "\\&lt;", s); gsub(/>/, "\\&gt;", s)
        return s
    }
    function css_of(p,   c) {
        c = ""
        if (p ~ /(^|,)1(,|$)/) c = c "font-weight:700;"
        if (p ~ /(^|,)2(,|$)/) c = c "opacity:.65;"
        if (p ~ /31/) c = c "color:#f14c4c;"
        else if (p ~ /32/) c = c "color:#23d18b;"
        else if (p ~ /33/) c = c "color:#e5c07b;"
        else if (p ~ /34/) c = c "color:#3b8eea;"
        else if (p ~ /35/) c = c "color:#d670d6;"
        else if (p ~ /36/) c = c "color:#29b8db;"
        else if (p ~ /37/) c = c "color:#e6e6e6;"
        else if (p ~ /38;5;208|38,5,208/) c = c "color:#ff8c00;"
        return c
    }
    BEGIN {
        open = 0
    }
    {
        line = $0 "\n"
        while ((i = index(line, esc "[")) > 0) {
            printf "%s", hesc(substr(line, 1, i - 1))
            rest = substr(line, i + 2)
            m = index(rest, "m")
            if (m == 0) { line = rest; break }
            params = substr(rest, 1, m - 1)
            line = substr(rest, m + 1)
            gsub(/;/, ",", params)
            if (params == "" || params == "0" || params == "00,") {
                if (open) { printf "</span>"; open = 0 }
                continue
            }
            c = css_of(params)
            if (c == "") continue
            if (open) printf "</span>"
            printf "<span style=\"%s\">", c
            open = 1
        }
        printf "%s", hesc(line)
        if (open) { printf "</span>"; open = 0 }
    }
    '
}

wu_html_page() {
    local body title
    title="${_WU_NAME:-${_WU_TOOLNAME}} v${_WU_VERSION}"
    body=$(printf '%s' "$1" | wu_ansi_to_html)
    printf '<!DOCTYPE html>\n<html lang="%s">\n<head>\n<meta charset="utf-8">\n<title>%s</title>\n<style>\nbody{background:#14161a;color:#e6e6e6;margin:24px;}\npre{font:13px/1.45 ui-monospace,SFMono-Regular,Menlo,Consolas,monospace;background:#1b1e24;padding:18px 22px;border-radius:10px;display:inline-block;}\nspan{white-space:pre-wrap;}\nfooter{opacity:.5;font:12px sans-serif;margin-top:10px;}\n</style>\n</head>\n<body>\n<pre>%s</pre>\n<footer>%s | %s</footer>\n</body>\n</html>\n' \
        "${WELLUTILS_LANG,,}" "$(_wu_html_esc "$title")" "$body" \
        "$(_wu_html_esc "$title")" "$(date -u '+%Y-%m-%d %H:%M UTC')"
}

# ─── JSON output helpers ──────────────────────────────────────────
json_esc() {
    local s="$1"
    s=${s//\\/\\\\}
    s=${s//\"/\\\"}
    s=${s//$'\n'/\\n}
    s=${s//$'\t'/\\t}
    s=${s//$'\r'/\\r}
    s=${s//$'\b'/\\b}
    s=${s//$'\f'/\\f}
    local rest="" out="" i c ord
    for (( i=0; i<${#s}; i++ )); do
        c="${s:$i:1}"
        printf -v ord '%d' "'$c" 2>/dev/null || ord=0
        if (( ord > 0 && ord < 32 )); then
            out+="$(printf '\\u%04x' "$ord")"
        else
            out+="$c"
        fi
    done
    printf '%s' "$out"
}

# Print the JSON envelope head (no trailing comma on the date field).
wu_json_head() {  # $1=tool  $2=version
    printf '{\n'
    printf '  "tool": "%s",\n' "$1"
    printf '  "version": "%s",\n' "$2"
    printf '  "date": "%s"' "$(json_esc "$(date '+%Y-%m-%d %H:%M:%S')")"
}

wu_json_end() { printf '\n}\n'; }

# Emit a JSON number when the value looks numeric, else null.
wu_json_num() {
    if [[ "$1" =~ ^-?[0-9]+(\.[0-9]+)?$ ]]; then
        printf '%s' "$1"
    else
        printf 'null'
    fi
}

# Emoji emitters: strip VS16 (U+FE0F) so terminals that render the bare
# codepoint narrow agree with our column math (no half-wide surprises).
_emoji_clean() { local e="$1"; printf '%s' "${e//$'\uFE0F'/}"; }
_emu() { [[ "$_WU_EMOJI" == "yes" ]] && _emoji_clean "$1"; return 0; }
_ic()  { [[ "$_WU_EMOJI" == "yes" ]] && _emoji_clean "$1"; printf ' '; return 0; }

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
_wu_pad_r() {
    # right-pad to N display columns; bash %-Ns pads by *bytes*, so labels
    # with multibyte text (Cyrillic) never align -- count display width instead
    local s="$1" n="$2" k
    k=$(( n - $(vislen "$s") ))
    (( k > 0 )) || k=0
    printf '%s%*s' "$s" "$k" ''
}

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