#!/usr/bin/env bash
# wellutils — cross-distro installer
# Works on any Linux: Arch/Manjaro (pacman), Fedora/RHEL (dnf/yum),
# Debian/Ubuntu/Bodhi/Mint/PopOS (apt), openSUSE (zypper), Alpine (apk),
# Void (xbps), Gentoo (emerge), ...
#
# One-line install:
#   curl -fsSL https://raw.githubusercontent.com/Wellbou/wellutils/main/install.sh | bash
#
# Or run from a checkout of the repo (installs the local files):
#   ./install.sh
# When invoked via `curl ... | bash` it always fetches the current
# sources from GitHub instead of reusing whatever is in the CWD.
set -euo pipefail

REPO="Wellbou/wellutils"
API="${WELLUTILS_API:-https://api.github.com/repos/$REPO}"
RAW="${WELLUTILS_RAW:-https://raw.githubusercontent.com/$REPO}"

PREFIX="${WELLUTILS_PREFIX:-/usr/local}"
BINDIR="$PREFIX/bin"
LIBDIR="$PREFIX/share/wellutils"
MANDIR="$PREFIX/share/man/man1"
LICDIR="$PREFIX/share/licenses/wellutils"
MANIFEST="$LIBDIR/wellutils.manifest"

COMPDIR="${WELLUTILS_COMPDIR:-}"
DO_DEPS=1
DO_FILES=1
DRY=0
UNINSTALL=0
SUDO=""

TOOLS="wellper wellmem wellhw wellusb wellpci wellblock wellcpu wellgpu wellmod wellsensors wellfetch wellup wellutils"
LIBS="lang.sh box.sh cli.sh jedec.sh wfetch_art.py logo.png VERSION"
MANPAGES="wellper.1 wellutils.1 wellfetch.1 wellhw.1 wellmem.1 wellusb.1 wellblock.1 wellpci.1 wellcpu.1 wellgpu.1 wellmod.1 wellsensors.1 wellup.1"
ALIASES="wellusb=wusb wellpci=wpci wellblock=wblock wellcpu=wcpu wellgpu=wgpu wellmem=wmem wellmem=wram wellmem=wellram wellmod=wmod wellsensors=wsensors wellsensors=wtemp wellhw=whw wellper=wper wellfetch=wfetch wellup=wup"

usage() {
    cat <<EOF
wellutils installer — cross-distro (Arch, Fedora, Debian, Ubuntu, Bodhi, ...)

Usage: install.sh [options]

Options:
  --no-deps        skip installing optional dependencies (tools degrade
                   gracefully, e.g. no SMART / sensor / vendor-ID data)
  --deps-only      install dependencies and stop before copying files
  --prefix=PATH    install prefix (default: /usr/local)
  --uninstall      remove files installed previously (uses a manifest)
  --dry-run        print what would be done, change nothing
  --help           show this help

Environment:
  WELLUTILS_PREFIX    same as --prefix
  WELLUTILS_COMPDIR   bash-completion directory override
  WELLUTILS_LOCAL=1   force using a local checkout (default: only when
                      run interactively as ./install.sh)
  WELLUTILS_RAW       raw.githubusercontent.com base URL override
  WELLUTILS_API       api.github.com base URL override
EOF
}

need_root() {
    local can_write=0
    if [[ $DRY -eq 1 ]]; then
        SUDO=""; return 0
    fi
    if [[ "$(id -u)" -eq 0 ]]; then
        SUDO=""; return 0
    fi
    if [[ -d "$PREFIX" && -w "$PREFIX" ]]; then
        can_write=1
    elif [[ ! -e "$PREFIX" ]] && mkdir -p "$PREFIX" 2>/dev/null; then
        can_write=1
    fi
    if [[ $can_write -eq 1 ]]; then
        SUDO=""
    elif command -v sudo >/dev/null 2>&1; then
        SUDO="sudo"
    else
        echo "error: need root (or sudo) to install into $PREFIX" >&2
        exit 1
    fi
}

run() {
    if [[ $DRY -eq 1 ]]; then
        printf '  %s%s\n' "${SUDO:+$SUDO }" "$*"
    elif [[ -n "$SUDO" ]]; then
        "$SUDO" "$@"
    else
        "$@"
    fi
}

# ─── package manager detection ────────────────────────────────
# ─── package manager detection (os-release first, PATH as fallback) ──
detect_pm() {
    local id="" id_like="" c="" osrelease
    osrelease="${WELLUTILS_OSRELEASE:-/etc/os-release}"
    if [[ -r "$osrelease" ]]; then
        . "$osrelease" 2>/dev/null || true
        id="${ID:-}" id_like="${ID_LIKE:-}"
    fi
    case "$id" in
        arch|manjaro|endeavouros|cachyos|artix)        c=pacman ;;
        fedora|rhel|centos|rocky|almalinux|nobara|eurolinux) c=dnf ;;
        debian|ubuntu|bodhi|linuxmint|pop|elementary|zorin|kali|mx|devuan) c=apt-get ;;
        opensuse*|sles|sled)                            c=zypper ;;
        alpine)                                         c=apk ;;
        void)                                           c=xbps-install ;;
        gentoo|calculate)                               c=emerge ;;
    esac
    case " $id_like " in
        *" arch "*)     c=pacman ;;
        *" fedora "*|*" rhel "*|*" centos "*) c=dnf ;;
        *" debian "*|*" ubuntu "*) c=apt-get ;;
        *" suse "*)     c=zypper ;;
    esac
    if [[ -n "$c" ]] && command -v "$c" >/dev/null 2>&1; then
        echo "$c"
        return 0
    fi
    for c in pacman dnf yum apt-get apt zypper apk xbps-install emerge; do
        if command -v "$c" >/dev/null 2>&1; then
            echo "$c"
            return 0
        fi
    done
    echo ""
}

os_label() {
    [[ -r /etc/os-release ]] || { echo "unknown Linux"; return; }
    . /etc/os-release 2>/dev/null || true
    echo "${PRETTY_NAME:-${NAME:-unknown Linux}}"
}

pm_install() {
    [[ -n "$PM" ]] || return 1
    local pkgs=("$@")
    [[ ${#pkgs[@]} -eq 0 ]] && return 0
    echo "==> $os: installing: ${pkgs[*]}"
    case "$PM" in
        pacman)      run pacman -S --noconfirm --needed "${pkgs[@]}" ;;
        dnf)         run dnf install -y "${pkgs[@]}" ;;
        yum)         run yum install -y "${pkgs[@]}" ;;
        apt-get)     run apt-get install -y --no-install-recommends "${pkgs[@]}" ;;
        apt)         run apt install -y --no-install-recommends "${pkgs[@]}" ;;
        zypper)      run zypper --non-interactive install "${pkgs[@]}" ;;
        apk)         run apk add "${pkgs[@]}" ;;
        xbps-install) run xbps-install -y "${pkgs[@]}" ;;
        emerge)      run emerge --noreplace "${pkgs[@]}" ;;
    esac
}

# ─── dependency sets per package manager ──────────────────────
deps_for() {
    case "$1" in
        pacman)        echo "bash coreutils util-linux procps-ng python hwdata lm_sensors smartmontools dmidecode" ;;
        dnf|yum)       echo "bash coreutils util-linux procps-ng python3 hwdata lm_sensors smartmontools dmidecode" ;;
        apt-get|apt)   echo "bash coreutils util-linux procps python3 usbutils pciutils lm-sensors smartmontools dmidecode" ;;
        zypper)        echo "bash coreutils util-linux procps python3 hwdata lm_sensors smartmontools dmidecode" ;;
        apk)           echo "bash coreutils util-linux procps python3 hwdata lm_sensors smartmontools dmidecode" ;;
        xbps-install)  echo "bash coreutils util-linux procps-ng python3 hwdata lm_sensors smartmontools dmidecode" ;;
        emerge)        echo "app-shells/bash sys-apps/coreutils sys-apps/util-linux sys-process/procps dev-lang/python sys-apps/hwdata sys-apps/lm-sensors sys-apps/smartmontools sys-apps/dmidecode" ;;
    esac
}

# ─── fetch sources (local checkout or GitHub tarball) ─────────
acquire_source() {
    local here
    here="$(cd -- "$(dirname -- "$0")" && pwd 2>/dev/null || pwd)"
    # Local checkout is used only when running the script directly (or with
    # WELLUTILS_LOCAL=1). A `curl ... | bash` pipe always downloads the
    # current sources — otherwise a stale clone would shadow the fresh
    # installer and mix versions.
    if [[ "${WELLUTILS_LOCAL:-0}" == "1" || -t 0 ]] \
       && [[ -f "$here/wellmem" && -f "$here/lang.sh" && -f "$here/wellutils" ]]; then
        if ! grep -q -- '--json' "$here/cli.sh" 2>/dev/null || ! grep -q 'json_out' "$here/wellmem" 2>/dev/null; then
            echo "warning: local checkout looks outdated (no --json support)." >&2
            echo "         Run 'git pull', or just use the GitHub one-liner." >&2
        fi
        echo "==> using local checkout: $here" >&2
        echo "$here"
        return 0
    fi

    echo "==> downloading wellutils source from GitHub..." >&2
    local tmp url ref
    tmp="$(mktemp -d)"
    _WU_INST_TMP="$tmp"
    trap '[[ -n "$_WU_INST_TMP" ]] && rm -rf -- "$_WU_INST_TMP"' EXIT
    ref="main"
    if command -v curl >/dev/null 2>&1 || command -v wget >/dev/null 2>&1; then :; else
        echo "error: need curl or wget to download the source" >&2
        exit 1
    fi
    if command -v curl >/dev/null 2>&1; then
        tag="$(curl -fsSL "$API/releases/latest" 2>/dev/null | grep -o '"tag_name"[^,]*' | sed 's/.*"tag_name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/')" || true
    else
        tag=""
    fi
    [[ -n "$tag" ]] && ref="$tag"
    url="https://codeload.github.com/$REPO/tar.gz/refs/$([[ "$ref" == "main" ]] && echo heads/$ref || echo tags/$ref)"
    echo "==> fetching ref: $ref" >&2
    if command -v curl >/dev/null 2>&1; then
        curl -fsSL "$url" -o "$tmp/wellutils.tar.gz"
    else
        wget -qO "$tmp/wellutils.tar.gz" "$url"
    fi
    tar -xzf "$tmp/wellutils.tar.gz" -C "$tmp"
    local d
    d="$(find "$tmp" -maxdepth 1 -type d | tail -n1)"
    echo "$d"
}

# ─── completions directory ────────────────────────────────────
pick_compdir() {
    [[ -n "$COMPDIR" ]] && { echo "$COMPDIR"; return 0; }
    case "$PREFIX" in
        /usr|/usr/local)
            if [[ -d /usr/share/bash-completion/completions ]]; then
                echo /usr/share/bash-completion/completions
            elif [[ -d /etc/bash_completion.d ]]; then
                echo /etc/bash_completion.d
            else
                echo /etc/bash_completion.d
            fi
            ;;
        *)
            echo "$PREFIX/share/bash-completion/completions"
            ;;
    esac
}

# ─── install files ─────────────────────────────────────────────
do_install() {
    local src="$1" t f compdir
    echo "==> $os: installing wellutils to $PREFIX"
    need_root
    run install -d "$BINDIR" "$LIBDIR" "$MANDIR"
    for t in $TOOLS; do
        run install -m755 "$src/$t" "$BINDIR/$t"
    done
    local base
    for a in $ALIASES; do
        base="${a%%=*}"
        run ln -sf "$BINDIR/$base" "$BINDIR/${a#*=}"
    done
    for f in $LIBS; do
        run install -m644 "$src/$f" "$LIBDIR/$f"
    done
    for f in $MANPAGES; do
        run install -m644 "$src/$f" "$MANDIR/$f"
    done
    if [[ -f "$src/LICENSE" ]]; then
        run install -d "$LICDIR"
        run install -m644 "$src/LICENSE" "$LICDIR/LICENSE"
    fi
    compdir="$(pick_compdir)"
    run install -d "$compdir"
    for f in "$src"/*.bash; do
        run install -m644 "$f" "$compdir/$(basename "${f%.bash}")" \
            || echo "    warning: could not write $compdir (completions optional)" >&2
    done

    # manifest for --uninstall
    run install -m644 /dev/null "$MANIFEST" || echo "    warning: could not write $MANIFEST" >&2
    {
        for t in $TOOLS; do
            echo "$BINDIR/$t"
        done
        for a in $ALIASES; do
            echo "$BINDIR/${a#*=}"
        done
        for f in $LIBS; do
            echo "$LIBDIR/$f"
        done
        for f in $MANPAGES; do
            echo "$MANDIR/$f"
        done
        echo "$LICDIR/LICENSE"
        for f in "$src"/*.bash; do
            echo "$compdir/$(basename "${f%.bash}")"
        done
        echo "$MANIFEST"
    } | run tee "$MANIFEST" >/dev/null
}

# ─── uninstall ────────────────────────────────────────────────
do_uninstall() {
    need_root
    if [[ ! -f "$MANIFEST" ]]; then
        echo "==> no manifest at $MANIFEST; nothing to remove"
        echo "    (files installed by a distro package are managed by that package)"
        return 0
    fi
    echo "==> removing files listed in $MANIFEST"
    while IFS= read -r f; do
        [[ -n "$f" ]] && run rm -f "$f"
    done < "$MANIFEST"
    run rm -f "$MANIFEST"
    run rmdir "$BINDIR" "$LIBDIR" "$MANDIR" "$LICDIR" 2>/dev/null || true
}

# ─── main ─────────────────────────────────────────────────────
for arg in "$@"; do
    case "$arg" in
        --help)        usage; exit 0 ;;
        --no-deps)     DO_DEPS=0 ;;
        --deps-only)   DO_FILES=0 ;;
        --uninstall)   UNINSTALL=1 ;;
        --dry-run)     DRY=1 ;;
        --prefix=*)    PREFIX="${arg#*=}"; BINDIR="$PREFIX/bin"; LIBDIR="$PREFIX/share/wellutils"; MANDIR="$PREFIX/share/man/man1"; LICDIR="$PREFIX/share/licenses/wellutils"; MANIFEST="$LIBDIR/wellutils.manifest" ;;
        *) echo "error: unknown option: $arg" >&2; usage >&2; exit 2 ;;
    esac
done

os="$(os_label)"
PM="$(detect_pm)"

if [[ $UNINSTALL -eq 1 ]]; then
    do_uninstall
    exit 0
fi

need_root

if [[ $DO_DEPS -eq 1 ]]; then
    if [[ -n "$PM" ]]; then
        echo "==> $os: package manager: $PM"
        read -r -a pkgs <<< "$(deps_for "$PM")"
        pm_install "${pkgs[@]}" || echo "    warning: dependency install reported a problem (continuing anyway)"
    else
        echo "==> $os: no known package manager detected; installing files only"
    fi
fi

if [[ $DO_FILES -eq 0 ]]; then
    echo "==> dependencies done (--deps-only)."
    exit 0
fi

SRC="$(acquire_source)"
do_install "$SRC"

echo
echo "==> wellutils installed."
echo "    binaries:  $BINDIR"
echo "    data:      $LIBDIR"
echo "    man:       $MANDIR"
if [[ "$PREFIX" == "/usr/local" || "$PREFIX" == "/usr" ]]; then
    echo '    try:       wellfetch | wellmem | wellusb | wellhw'
else
    echo "    note:      custom prefix is self-contained (data at $PREFIX/share/wellutils)"
fi
