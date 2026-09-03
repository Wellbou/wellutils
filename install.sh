#!/usr/bin/env bash
# wellutils -- cross-distro installer
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

TOOLS="wellper wellmem wellhw wellusb wellpci wellblock wellcpu wellgpu wellmod wellsensors wellfetch wellup wellnet wellpower welldoctor whtml wellutils"
LIBS="lang.sh box.sh cli.sh bootstrap.sh jedec.sh distro_art.sh wfetch_art.py logo.png VERSION"
MANPAGES="wellper.1 wellutils.1 wellfetch.1 wellhw.1 wellmem.1 wellusb.1 wellblock.1 wellpci.1 wellcpu.1 wellgpu.1 wellmod.1 wellsensors.1 wellup.1 wellnet.1 wellpower.1 welldoctor.1 whtml.1"
ALIASES="wellusb=wusb wellpci=wpci wellblock=wblock wellcpu=wcpu wellgpu=wgpu wellmem=wmem wellmem=wram wellmem=wellram wellmod=wmod wellsensors=wsensors wellsensors=wtemp wellhw=whw wellper=wper wellfetch=wfetch wellup=wup wellnet=wnet wellpower=wpower wellpower=wbatt welldoctor=wdoc welldoctor=wdoctor"

usage() {
    cat <<EOF
wellutils installer -- cross-distro (Arch, Fedora, Debian, Ubuntu, Bodhi, ...)

Usage: install.sh [options]

Options:
  --no-deps        skip installing optional dependencies (tools degrade
                   gracefully, e.g. no SMART / sensor / vendor-ID data)
  --deps-only      install dependencies and stop before copying files
  --prefix=PATH    install prefix (default: /usr/local)
  --uninstall      remove files installed previously (uses a manifest)
  --dry-run        print what would be done, change nothing
  --hardware       show detected kernel / hardware profile and exit
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
        fedora|rhel|centos|rocky|almalinux|nobara|eurolinux|nobara|serinux) c=dnf ;;
        debian|ubuntu|bodhi|linuxmint|pop|elementary|zorin|kali|mx|devuan|parrot|raspbian|raspberry*os|astra|ALT|altlinux) c=apt-get ;;
        opensuse*|sles|sled)                            c=zypper ;;
        alpine|postmarketos|chainguard)                 c=apk ;;
        void)                                           c=xbps-install ;;
        gentoo|calculate|funtoo)                        c=emerge ;;
        nixos|nix)                                      c=nix-env ;;
        solus)                                          c=eopkg ;;
        crux|crux*)                                     c=ports ;;
        openwrt|immich)                                 c=opkg ;;
        tuxedo|tuxedos)                                 c=apt-get ;;
        ol|oracle|amzn|clear-linux-os|eurolinux|anolis) c=dnf ;;
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
    for c in pacman dnf yum apt-get apt zypper apk xbps-install emerge eopkg opkg; do
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

# ─── kernel / hardware detection ─────────────────────────────
detect_kernel() {
    local kv
    kv=$(uname -r 2>/dev/null) || { echo "unknown"; return; }
    echo "$kv"
}

kernel_major() {
    echo "${1%%.*}"
}

detect_hardware_profile() {
    local hw="generic" kv="${1:-}"
    local kmaj="${2:-}"
    # Xbox 360
    if [[ -r /proc/device-tree/model ]]; then
        local dtmodel
        dtmodel=$(tr -d '\0' < /proc/device-tree/model 2>/dev/null)
        case "$dtmodel" in
            *Xbox*|*XBOX*|*xbox*) hw="xbox360" ;;
            *Raspberry*|*raspberry*) hw="rpi" ;;
            *BeagleBone*|*beaglebone*) hw="beaglebone" ;;
            *Google*|*google*chromebook*) hw="chromebook" ;;
        esac
    fi
    # ARM / embedded checks
    if [[ -d /sys/class/thermal ]]; then
        local cnt
        cnt=$(ls -d /sys/class/thermal/cooling_device* 2>/dev/null | wc -l)
        (( cnt > 10 )) && hw="${hw}:embedded-thermal"
    fi
    # Old kernel detection
    if [[ -n "$kmaj" ]]; then
        if (( kmaj <= 2 )); then
            hw="${hw}:legacy-2.x"
        elif (( kmaj <= 3 )); then
            hw="${hw}:legacy-3.x"
        fi
    fi
    # Console-only (no display server)
    if [[ -z "${DISPLAY:-}" ]] && [[ -z "${WAYLAND_DISPLAY:-}" ]]; then
        hw="${hw}:headless"
    fi
    echo "$hw"
}

# Detect rare / exotic hardware -- warns user about edge cases
detect_exotic_hardware() {
    local warnings=""
    # Old USB controllers (kernel 2.6 era USB stack)
    if [[ -d /proc/bus/usb ]]; then
        warnings+="  note: /proc/bus/usb detected (legacy USB, kernel < 2.6.31)\n"
    fi
    # ISA/PCMCIA buses
    if [[ -d /sys/bus/isa ]]; then
        warnings+="  note: ISA bus detected (legacy hardware)\n"
    fi
    if [[ -d /sys/bus/pcmcia ]]; then
        warnings+="  note: PCMCIA/CardBus detected\n"
    fi
    # Xen / KVM / Docker / containers
    if [[ -r /proc/xen/capabilities ]]; then
        warnings+="  note: running in Xen domain\n"
    fi
    if grep -q "hypervisor" /proc/cpuinfo 2>/dev/null; then
        warnings+="  note: running in a virtual machine\n"
    fi
    if [[ -f /.dockerenv ]] || grep -q "docker" /proc/1/cgroup 2>/dev/null; then
        warnings+="  note: running inside Docker container\n"
    fi
    # WSL
    if uname -r 2>/dev/null | grep -qi microsoft; then
        warnings+="  note: running under WSL (Windows Subsystem for Linux)\n"
    fi
    printf '%b' "$warnings"
}

pm_install() {
    [[ -n "$PM" ]] || return 1
    local pkgs=("$@")
    [[ ${#pkgs[@]} -eq 0 ]] && return 0
    echo "==> $os: installing: ${pkgs[*]}"
    # Install one package at a time so a single unavailable/conflicting
    # package (or one already installed) degrades to a warning instead of
    # making the package manager abort the whole transaction -- otherwise
    # one bad name silently blocks python3, dmidecode, etc., which leaves
    # whtml/wellhw broken even though --no-deps promised graceful degrade.
    local _rc=0 _p
    for _p in "${pkgs[@]}"; do
        case "$PM" in
            pacman)      run pacman -S --noconfirm --needed "$_p" ;;
            dnf)         run dnf install -y --allowerasing "$_p" ;;
            yum)         run yum install -y --allowerasing "$_p" ;;
            apt-get)     run apt-get install -y --no-install-recommends "$_p" ;;
            apt)         run apt install -y --no-install-recommends "$_p" ;;
            zypper)      run zypper --non-interactive install "$_p" ;;
            apk)         run apk add "$_p" ;;
            xbps-install) run xbps-install -y "$_p" ;;
            emerge)      run emerge --noreplace "$_p" ;;
            eopkg)       run eopkg install -y "$_p" ;;
            nix-env)     run nix-env -iA "$_p" ;;
            opkg)        run opkg install "$_p" ;;
        esac || { echo "    warning: package manager failed for: $_p" >&2; _rc=1; }
    done
    unset _p
    return "$_rc"
}

# ─── dependency sets per package manager ──────────────────────
deps_for() {
    case "$1" in
        pacman)        echo "bash coreutils util-linux procps-ng python hwdata lm_sensors smartmontools dmidecode pciutils" ;;
        dnf|yum)       echo "bash coreutils util-linux procps-ng python3 hwdata lm_sensors smartmontools dmidecode pciutils" ;;
        apt-get|apt)   echo "bash coreutils util-linux procps python3 hwdata pciutils lm-sensors smartmontools dmidecode" ;;
        zypper)        echo "bash coreutils util-linux procps python3 hwdata sensors smartmontools dmidecode pciutils" ;;
        apk)           echo "bash coreutils util-linux procps python3 hwdata lm_sensors smartmontools dmidecode pciutils" ;;
        xbps-install)  echo "bash coreutils util-linux procps-ng python3 lm_sensors smartmontools dmidecode pciutils" ;;
        emerge)        echo "app-shells/bash sys-apps/coreutils sys-apps/util-linux sys-process/procps dev-lang/python sys-apps/hwdata sys-apps/lm-sensors sys-apps/smartmontools sys-apps/dmidecode sys-apps/pciutils" ;;
        nix-env)       echo "nixpkgs.bash nixpkgs.coreutils nixpkgs.util-linux nixpkgs.procps nixpkgs.python3 nixpkgs.dmidecode nixpkgs.smartmontools nixpkgs.lm_sensors nixpkgs.pciutils" ;;
        eopkg)         echo "bash coreutils util-linux procps python3 hwdata lm_sensors smartmontools dmidecode pciutils" ;;
        opkg)          echo "" ;;
    esac
}

# ─── fetch sources (local checkout or GitHub tarball) ─────────
acquire_source() {
    local here
    here="$(cd -- "$(dirname -- "$0")" && pwd 2>/dev/null || pwd)"
    # Local checkout is used only when running the script directly (or with
    # WELLUTILS_LOCAL=1). A `curl ... | bash` pipe always downloads the
    # current sources -- otherwise a stale clone would shadow the fresh
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
    ref="main"
    if command -v curl >/dev/null 2>&1 || command -v wget >/dev/null 2>&1; then :; else
        echo "error: need curl or wget to download the source" >&2
        rm -rf -- "$tmp"
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
        curl -fsSL "$url" -o "$tmp/wellutils.tar.gz" || { rm -rf -- "$tmp"; exit 1; }
    else
        wget -qO "$tmp/wellutils.tar.gz" "$url" || { rm -rf -- "$tmp"; exit 1; }
    fi
    tar -xzf "$tmp/wellutils.tar.gz" -C "$tmp" || { rm -rf -- "$tmp"; exit 1; }
    # IMPORTANT: do NOT trap EXIT here -- this function is called via
    # `SRC="$(acquire_source)"` (command substitution). An EXIT trap in the
    # subshell would delete the unpacked tarball before the parent shell
    # gets a chance to install it. Return the tarball dir on stdout; the
    # parent re-computes $tmp = dirname($SRC) and sets the trap itself.
    local d
    d="$(find "$tmp" -maxdepth 1 -type d | tail -n1)"
    printf '%s\n' "$d"
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
    # zsh + fish completions (best effort)
    if [[ -d /usr/share/zsh/site-functions && -d "$src/completions/zsh" ]]; then
        for f in "$src"/completions/zsh/_*; do
            [[ -f "$f" ]] || continue
            run install -m644 "$f" "/usr/share/zsh/site-functions/$(basename "$f")" || true
        done
        echo "  zsh completions installed to /usr/share/zsh/site-functions"
    fi
    if [[ -d /usr/share/fish/vendor_completions.d && -d "$src/completions/fish" ]]; then
        for f in "$src"/completions/fish/*.fish; do
            [[ -f "$f" ]] || continue
            run install -m644 "$f" "/usr/share/fish/vendor_completions.d/$(basename "$f")" || true
        done
        echo "  fish completions installed to /usr/share/fish/vendor_completions.d"
    fi

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
        --hardware)    _kver="$(detect_kernel)"; _kmaj="$(kernel_major "$_kver")"; echo "kernel: $_kver"; echo "profile: $(detect_hardware_profile "$_kver" "$_kmaj")"; detect_exotic_hardware; exit 0 ;;
        --prefix=*)    PREFIX="${arg#*=}"; BINDIR="$PREFIX/bin"; LIBDIR="$PREFIX/share/wellutils"; MANDIR="$PREFIX/share/man/man1"; LICDIR="$PREFIX/share/licenses/wellutils"; MANIFEST="$LIBDIR/wellutils.manifest" ;;
        *) echo "error: unknown option: $arg" >&2; usage >&2; exit 2 ;;
    esac
done

os="$(os_label)"
PM="$(detect_pm)"
_kver="$(detect_kernel)"
_kmaj="$(kernel_major "$_kver")"
_hwprof="$(detect_hardware_profile "$_kver" "$_kmaj")"

echo "==> $os"
echo "    kernel:   $_kver"
[[ "$_hwprof" != "generic" ]] && echo "    hardware: $_hwprof"
_exotic="$(detect_exotic_hardware)"
[[ -n "$_exotic" ]] && printf '%s' "$_exotic"

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

# acquire_source must NOT trap EXIT itself (it runs in a command subshell,
# and the trap would delete the tarball before install begins). It returns
# the tarball dir on stdout; recompute the tmpdir and clean it up here.
SRC="$(acquire_source)"
_WU_INST_TMP="$(dirname "$SRC")"
if [[ "$_WU_INST_TMP" == "/tmp/"* || "$_WU_INST_TMP" == /tmp/tmp.* ]]; then
    trap '[[ -n "$_WU_INST_TMP" && -d "$_WU_INST_TMP" ]] && rm -rf -- "$_WU_INST_TMP"' EXIT
fi
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
