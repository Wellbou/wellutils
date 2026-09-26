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
# shellcheck shell=bash

# Lowercase without forking tr (bash >= 4 ${var,,}); kept for callers.
_wlc() { printf '%s' "${1,,}"; }

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

    _WU_COLOR=${_WU_COLOR,,}
    case "$_WU_COLOR" in
        always|auto|never) : ;;
        *) printf '%s: --color must be always|auto|never\n' "$_WU_TOOLNAME" >&2; exit 2 ;;
    esac
    _WU_LANG_ARG=${_WU_LANG_ARG,,}
    case "$_WU_LANG_ARG" in
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

    case "$_WU_LANG_ARG" in
        ru) WELLUTILS_LANG=RU ;;
        en) WELLUTILS_LANG=EN ;;
        auto) _wu_detect_lang ;;
        "") : ;;
    esac

    [[ "$_WU_DEBUG" == "1" ]] && set -x
    return 0
}

# Real terminal width. COLUMNS is a non-exported shell variable, so scripts
# never see it; ask the tty (stty works on busybox/Termux too), then tput.
_wu_detect_cols() {
    local c="" _r
    if [[ ! "${COLUMNS:-}" =~ ^[0-9]+$ ]] || (( ${COLUMNS:-0} < 20 )); then
        if [[ -t 1 || -t 2 ]] && command -v stty >/dev/null 2>&1; then
            _r=$(stty size 2>/dev/null </dev/tty) && c=${_r##* }
        fi
        [[ "$c" =~ ^[0-9]+$ ]] || c=$(tput cols 2>/dev/null </dev/tty) || c=""
        [[ "$c" =~ ^[0-9]+$ ]] && (( c >= 20 )) || c=100
        COLUMNS=$c
    fi
    # Frames larger than the terminal wrap and look broken; when piped
    # (--box > file) keep a generous default instead.
    [[ -t 1 ]] || { [[ -n "${_WU_COLS_SET:-}" ]] || COLUMNS=${WELLUTILS_COLUMNS:-120}; }
    return 0
}

# Does the locale speak UTF-8? (C.UTF-8 / en_US.utf8 do; C / POSIX don't.)
_wu_locale_utf8() {
    local l="${LC_ALL:-${LC_CTYPE:-${LANG:-}}}"
    case "${l,,}" in
        *utf-8*|*utf8*) return 0 ;;
        ""|c|posix|c.*|posix.*) return 1 ;;
        *) return 0 ;;   # e.g. "ru_RU" on systems where UTF-8 is implied
    esac
}

wu_run() {
    local fn="$1"; shift
    # Numbers must use "." whatever the user's locale (ru_RU/de_DE print
    # "3,70" from printf %f / awk and break JSON and column math).
    export LC_NUMERIC=C
    [[ -n "${COLUMNS:-}" ]] && _WU_COLS_SET=1
    wu_parse "$@"
    _wu_detect_cols

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

    # Linux virtual console (TERM=linux: netbooks, rescue shells, Xbox 360
    # framebuffer) has a 512-glyph font: box lines yes, emoji never.
    if [[ "$_WU_EMOJI" == "auto" ]]; then
        if ! _wu_locale_utf8 || [[ "${TERM:-}" == "dumb" || "${TERM:-}" == "linux" || "${TERM:-}" == "vt"* ]]; then
            _WU_EMOJI="no"
        else
            _WU_EMOJI="yes"
        fi
    fi

    # Detect Unicode box-drawing support. Terminals that lack it get
    # plain mode automatically (ASCII boxes look worse than no boxes).
    _WU_UNICODE=1
    _wu_locale_utf8 || _WU_UNICODE=0
    [[ "${TERM:-}" == "dumb" || "${TERM:-}" == "vt"* ]] && _WU_UNICODE=0
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
        if [[ "$_WU_MANUAL" == "1" ]] && declare -F _wu_reframe >/dev/null; then
            out=$(_wu_reframe "$out")
        fi
        wu_html_page "$out"
        return "$_fn_rc"
    fi

    if [[ $_WU_COLOR_ON -eq 0 ]]; then
        R= G= Y= B= M= C= W= DIM= BOLD= RESET=
        ORANGE= RED_BG=
    fi

    if [[ "$_WU_MANUAL" == "1" && "$_WU_JSON" != "1" ]]; then
        local out _fn_rc=0
        out=$("$fn") || _fn_rc=$?
        if [[ "$_WU_PLAIN" == "1" ]]; then
            _wu_plainify "$out"
        elif declare -F _wu_reframe >/dev/null; then
            _wu_reframe "$out"
        else
            printf '%s\n' "$out"
        fi
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
# _wu_utf8_fix STR VAR -- replace every byte that is not part of a valid
# UTF-8 sequence with '?' (Latin-1 firmware strings like "Kingst\xf6n" would
# otherwise make the whole JSON document invalid). Pure bash, byte-wise under
# LC_ALL=C; callers only use it when a non-ASCII byte is present.
_wu_utf8_fix() {
    local LC_ALL=C __s="$1" __o="" __c __n __i __j __k __len=${#1}
    # Long texts (reports, logs): one iconv fork beats a per-byte bash loop.
    # iconv -c drops invalid bytes instead of '?'; still valid JSON.
    if (( __len > 2048 )) && command -v iconv >/dev/null 2>&1; then
        # (-c returns 1 when it dropped bytes; an iconv without -c, e.g. some
        # musl builds, prints nothing -> fall back to the loop below)
        __o=$(printf '%s' "$__s" | iconv -c -f UTF-8 -t UTF-8 2>/dev/null; printf x) || __o=x
        __o=${__o%x}
        if [[ -n "$__o" ]]; then printf -v "$2" '%s' "$__o"; return 0; fi

    fi

    for (( __i=0; __i<__len; )); do
        __c=${__s:__i:1}
        case "$__c" in
            [$'\x01'-$'\x7f']) __o+=$__c; __i=$(( __i + 1 )); continue ;;
            [$'\xc2'-$'\xdf']) __n=1 ;;
            [$'\xe0'-$'\xef']) __n=2 ;;
            [$'\xf0'-$'\xf4']) __n=3 ;;
            *) __o+="?"; __i=$(( __i + 1 )); continue ;;
        esac
        __k=1
        for (( __j=1; __j<=__n; __j++ )); do
            case "${__s:__i+__j:1}" in
                [$'\x80'-$'\xbf']) : ;;
                *) __k=0; break ;;
            esac
        done
        if (( __k )); then __o+=${__s:__i:__n+1}; __i=$(( __i + __n + 1 ))
        else __o+="?"; __i=$(( __i + 1 )); fi
    done
    printf -v "$2" '%s' "$__o"
}

json_esc() {
    local s="$1" LC_ALL=C
    # Fast path for ASCII: only walk bytes when a high byte is present.
    [[ "$s" == *[$'\x80'-$'\xff']* ]] && _wu_utf8_fix "$s" s
    s=${s//\\/\\\\}
    s=${s//\"/\\\"}
    s=${s//$'\n'/\\n}
    s=${s//$'\t'/\\t}
    s=${s//$'\r'/\\r}
    s=${s//$'\b'/\\b}
    s=${s//$'\f'/\\f}
    # Fast path: no remaining control chars (the usual case) -> no per-char loop
    # (the loop costs one printf per character: 12 s on a 27 KB string).
    if [[ "$s" != *[$'\001'-$'\037'$'\177']* ]]; then printf '%s' "$s"; return; fi
    local out="" i c ord
    for (( i=0; i<${#s}; i++ )); do
        c="${s:$i:1}"
        printf -v ord '%d' "'$c" 2>/dev/null || ord=0
        if (( (ord > 0 && ord < 32) || ord == 127 )); then
            out+="$(printf '\\u%04x' "$ord")"
        else
            out+="$c"
        fi
    done
    printf '%s' "$out"
}

# Print the JSON envelope head (no trailing comma on the date field).
wu_json_head() {  # $1=tool  $2=version
    local sv=""
    [[ -r "${_WU_BOOT_DIR:-}/VERSION" ]] && { read -r sv < "$_WU_BOOT_DIR/VERSION" || [[ -n "$sv" ]]; }
    printf '{\n'
    printf '  "tool": "%s",\n' "$1"
    printf '  "version": "%s",\n' "$2"
    [[ -n "$sv" ]] && printf '  "suite_version": "%s",\n' "$(json_esc "$sv")"
    printf '  "date": "%s"' "$(json_esc "$(date '+%Y-%m-%d %H:%M:%S' 2>/dev/null)")"
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
# Built as raw UTF-8 bytes (EF B8 8F) -- avoids bash's $'\uFE0F' multibyte
# expansion, which bash < 4.2 does not support (and which depends on the
# current locale at parse time) -- raw bytes work everywhere.
_WU_VS16=$(printf '\357\270\217')
_emoji_clean() { local e="$1"; printf '%s' "${e//$_WU_VS16/}"; }
_emu() { [[ "$_WU_EMOJI" == "yes" ]] && _emoji_clean "$1"; return 0; }
_ic()  { [[ "$_WU_EMOJI" == "yes" ]] && _emoji_clean "$1"; printf ' '; return 0; }

_wu_pad_r() {
    # right-pad to N display columns; bash %-Ns pads by *bytes*, so labels
    # with multibyte text (Cyrillic) never align -- count display width instead
    local s="$1" n="$2" k _WU_VL
    if declare -F _wu_vislen_v >/dev/null; then _wu_vislen_v "$s"; else _WU_VL=${#s}; fi
    k=$(( n - _WU_VL ))
    (( k > 0 )) || k=0
    printf '%s%*s' "$s" "$k" ''
}

_wu_plainify() {
    # Box drawing U+2500..U+257F is E2 94 xx / E2 95 xx: two byte-level
    # substitutions per line instead of 128 (much faster on slow machines).
    local line out="" LC_ALL=C prev_blank=0
    while IFS= read -r line || [[ -n "$line" ]]; do
        line=${line//$'\xe2\x94'?/ }
        line=${line//$'\xe2\x95'?/ }
        line=${line//$'\t'/ }
        # collapse the runs of spaces left behind by the frames, keep a
        # two-space indent, drop trailing blanks
        while [[ "$line" == *"   "* ]]; do line=${line//   / }; done
        line=${line#"${line%%[! ]*}"}
        line=${line%"${line##*[! ]}"}
        if [[ -n "$line" ]]; then
            out+="  $line"$'\n'; prev_blank=0
        elif (( ! prev_blank )); then
            # squeeze repeated blank lines left over from removed frame rows
            out+=$'\n'; prev_blank=1
        fi
    done <<< "$1"
    printf '%s' "$out"
}
