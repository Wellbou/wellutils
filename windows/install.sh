#!/usr/bin/env bash
# wellutils installer for Git Bash / MSYS2 on Windows
# One-line install:
#   curl -fsSL https://raw.githubusercontent.com/Wellbou/wellutils/main/windows/install.sh | bash
set -euo pipefail

REPO="Wellbou/wellutils"
RAW="${WELLUTILS_RAW:-https://raw.githubusercontent.com/$REPO}"
API="${WELLUTILS_API:-https://api.github.com/repos/$REPO}"
DEST="$HOME/.wellutils"
BIN="$DEST/bin"
PWS="$BIN/well.ps1"
TOOLS="wellmem wellhw wellusb wellpci wellblock wellmod wellsensors wellper wellfetch"

fetch_well() {
    local ver="$1" out="$2"
    if command -v curl >/dev/null 2>&1; then
        curl -fsSL "$RAW/$ver/windows/well.ps1" -o "$out"
    else
        wget -q -O "$out" "$RAW/$ver/windows/well.ps1"
    fi
}

api_get() {
    if command -v curl >/dev/null 2>&1; then
        curl -fsSL "$1"
    else
        wget -qO- "$1"
    fi
}

# pure-bash version compare: rc 0 if $1 > $2
ver_gt() {
    local a="${1#v}" b="${2#v}" i x y
    local -a A B
    IFS='.-_' read -r -a A <<< "$a"
    IFS='.-_' read -r -a B <<< "$b"
    for (( i=0; i < ${#A[@]} || i < ${#B[@]}; i++ )); do
        x="${A[i]:-0}" y="${B[i]:-0}"
        if [[ "$x" =~ ^[0-9]+$ && "$y" =~ ^[0-9]+$ ]]; then
            (( 10#$x > 10#$y )) && return 0
            (( 10#$x < 10#$y )) && return 1
        else
            [[ "$x" > "$y" ]] && return 0
            [[ "$x" < "$y" ]] && return 1
        fi
    done
    return 1
}

TMPD="$(mktemp -d "${TMPDIR:-/tmp}/wellutils-win.XXXXXX")"
trap 'rm -rf -- "$TMPD"' EXIT
SRC_PS1="$TMPD/well.ps1"

# newest tag (a stale GitHub Release can lag far behind the tags)
tag=""
while IFS= read -r line; do
    line="${line##*:}"; line="${line//[[:space:]\"]/}"
    [[ "$line" == v[0-9]* ]] || continue
    if [[ -z "$tag" ]] || ver_gt "$line" "$tag"; then tag="$line"; fi
done < <(api_get "$API/tags?per_page=100" 2>/dev/null | grep -o '"name"[[:space:]]*:[[:space:]]*"[^"]*"' || true)

if [ -n "$tag" ] && fetch_well "$tag" "$SRC_PS1"; then
    echo "Found tag: $tag"
else
    echo "Using main branch."
    fetch_well main "$SRC_PS1"
fi

mkdir -p "$BIN"
install -m 0644 "$SRC_PS1" "$PWS"

cat > "$BIN/well.cmd" <<EOF
@echo off
powershell -NoProfile -ExecutionPolicy Bypass -File "$PWS" %*
EOF
for t in $TOOLS; do
    cat > "$BIN/$t.cmd" <<EOF
@echo off
powershell -NoProfile -ExecutionPolicy Bypass -File "$PWS" $t %*
EOF
done

case ":$PATH:" in
    *":$BIN:"*) : ;;
    *) grep -qF "$BIN" "$HOME/.bashrc" 2>/dev/null || cat >> "$HOME/.bashrc" <<EOF

# wellutils
export PATH="\$PATH:$BIN"
EOF
        echo "Added $BIN to PATH in ~/.bashrc (restart shells to use)."
        ;;
esac

echo "wellutils installed:"
echo "  scripts: $BIN"
echo 'Usage: open a NEW terminal and run:  well mem |  well fetch  |  well hw'
echo 'Aliases available too:  wellmem, wellusb, wellsensors, wfetch, ...'