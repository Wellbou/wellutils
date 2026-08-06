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
    curl -fsSL "$RAW/$ver/windows/well.ps1" -o "$out"
}

tag=""
if tag="$(curl -fsSL "$API/releases/latest" 2>/dev/null | grep -o '"tag_name"[^,]*' | sed 's/.*"tag_name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/')" \
   && [ -n "$tag" ] && fetch_well "$tag" /tmp/well-src.ps1; then
    echo "Found release: $tag"
else
    echo "Using main branch."
    fetch_well main /tmp/well-src.ps1
fi

mkdir -p "$BIN"
install -m 0644 /tmp/well-src.ps1 "$PWS"
rm -f /tmp/well-src.ps1

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