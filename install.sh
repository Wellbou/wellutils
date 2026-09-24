#!/usr/bin/env bash
# wellutils -- cross-distro installer
# Works on any Linux: Arch/Manjaro (pacman), Fedora/RHEL (dnf/yum),
# Debian/Ubuntu/Bodhi/Mint/PopOS (apt), openSUSE (zypper), Alpine (apk),
# Void (xbps), Gentoo (emerge), Solus (eopkg), OpenWrt (opkg),
# Clear Linux (swupd), Termux (pkg), NixOS / Slackware (files only).
#
# One-line install:
#   curl -fsSL https://raw.githubusercontent.com/Wellbou/wellutils/main/install.sh | bash
#   wget -qO- https://raw.githubusercontent.com/Wellbou/wellutils/main/install.sh | bash
#
# Or run from a checkout of the repo (installs the local files):
#   ./install.sh
# When invoked via `curl ... | bash` it always fetches the current
# sources from GitHub instead of reusing whatever is in the CWD.
set -euo pipefail

if [ -z "${BASH_VERSINFO:-}" ] || [ "${BASH_VERSINFO[0]}" -lt 4 ]; then
    echo "error: wellutils needs bash >= 4.0 (found ${BASH_VERSION:-none})." >&2
    echo "       On macOS: wellutils is Linux-only; the tools read /proc and /sys." >&2
    exit 1
fi

REPO="${WELLUTILS_REPO:-Wellbou/wellutils}"
API="${WELLUTILS_API:-https://api.github.com/repos/$REPO}"
RAW="${WELLUTILS_RAW:-https://raw.githubusercontent.com/$REPO}"

# Termux exports PREFIX=/data/data/com.termux/files/usr; remember it before
# our own PREFIX variable shadows it.
_ENV_PREFIX="${PREFIX:-}"
IS_TERMUX=0
if [[ -n "${TERMUX_VERSION:-}" || "$_ENV_PREFIX" == *com.termux* ]]; then
    IS_TERMUX=1
fi
IS_NIXOS=0
if [[ -e /etc/NIXOS ]] || grep -qs '^ID="\?nixos' "${WELLUTILS_OSRELEASE:-/etc/os-release}"; then
    IS_NIXOS=1
fi

if [[ -n "${WELLUTILS_PREFIX:-}" ]]; then
    PREFIX="$WELLUTILS_PREFIX"
elif (( IS_TERMUX )) && [[ -n "$_ENV_PREFIX" ]]; then
    PREFIX="$_ENV_PREFIX"
elif (( IS_NIXOS )); then
    PREFIX="${HOME:-/root}/.local"
else
    PREFIX="/usr/local"
fi

DO_DEPS=1
DO_FILES=1
DRY=0
UNINSTALL=0
SUDO=""
PM_SUDO=""
PM_OK=1

# Aliases: base=alias. Only created when the base tool is being installed.
ALIASES="wellutils=well wellutils=wutils wellusb=wusb wellpci=wpci wellblock=wblock wellcpu=wcpu wellgpu=wgpu wellmem=wmem wellmem=wram wellmem=wellram wellmod=wmod wellsensors=wsensors wellsensors=wtemp wellhw=whw wellper=wper wellfetch=wfetch wellup=wup wellnet=wnet wellpower=wpower wellpower=wbatt welldoctor=wdoc welldoctor=wdoctor"

set_paths() {
    BINDIR="$PREFIX/bin"
    LIBDIR="$PREFIX/share/wellutils"
    MANDIR="$PREFIX/share/man/man1"
    LICDIR="$PREFIX/share/licenses/wellutils"
    BASHCOMP="${WELLUTILS_COMPDIR:-$PREFIX/share/bash-completion/completions}"
    ZSHCOMP="$PREFIX/share/zsh/site-functions"
    FISHCOMP="$PREFIX/share/fish/vendor_completions.d"
    MANIFEST="$LIBDIR/wellutils.manifest"
}

usage() {
    cat <<EOF
wellutils installer -- cross-distro (Arch, Fedora, Debian, Ubuntu, Alpine,
Void, Gentoo, openSUSE, Termux, NixOS, ...)

Usage: install.sh [options]

Options:
  --no-deps        skip installing optional dependencies (tools degrade
                   gracefully, e.g. no SMART / sensor / vendor-ID data)
  --deps-only      install dependencies and stop before copying files
  --prefix=PATH    install prefix (default: /usr/local; Termux: \$PREFIX;
                   NixOS: ~/.local). Rootless: --prefix=\$HOME/.local
  --uninstall      remove files installed previously (uses a manifest)
  --dry-run        print what would be done, change nothing
  --hardware       show detected kernel / hardware profile and exit
  --help           show this help

Environment:
  WELLUTILS_PREFIX    same as --prefix
  WELLUTILS_COMPDIR   bash-completion directory override
  WELLUTILS_LOCAL=1   force using a local checkout (default: only when
                      run interactively as ./install.sh)
  WELLUTILS_REF       git ref (tag/branch) to download instead of the newest tag
  WELLUTILS_RAW       raw.githubusercontent.com base URL override
  WELLUTILS_API       api.github.com base URL override
EOF
}

# ─── helpers ──────────────────────────────────────────────────
have() { command -v "$1" >/dev/null 2>&1; }

# download URL -> FILE (curl or wget); FILE "-" = stdout
fetch() {
    local url="$1" out="$2"
    if have curl; then
        curl -fsSL --max-time 120 "$url" -o "$out"
    elif have wget; then
        wget -q -T 120 -O "$out" "$url"
    else
        return 127
    fi
}

# Pure-bash version compare (busybox sort has no -V). rc 0 if $1 > $2.
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

# newest version among stdin lines
ver_max() {
    local line best=""
    while IFS= read -r line; do
        [[ -z "$line" ]] && continue
        if [[ -z "$best" ]] || ver_gt "$line" "$best"; then best="$line"; fi
    done
    printf '%s' "$best"
}

need_root() {
    local can_write=0 d
    SUDO=""
    [[ $DRY -eq 1 ]] && return 0
    [[ "$(id -u)" -eq 0 ]] && return 0
    # nearest existing ancestor of PREFIX decides writability
    d="$PREFIX"
    while [[ ! -e "$d" && "$d" != "/" && -n "$d" ]]; do d="$(dirname "$d")"; done
    [[ -d "$d" && -w "$d" ]] && can_write=1
    if [[ -d "$PREFIX" && ! -w "$PREFIX" ]]; then can_write=0; fi
    if [[ -d "$PREFIX/bin" && ! -w "$PREFIX/bin" ]]; then can_write=0; fi
    if [[ $can_write -eq 1 ]]; then
        SUDO=""
    elif (( ! IS_TERMUX )) && have sudo; then
        SUDO="sudo"
    elif (( ! IS_TERMUX )) && have doas; then
        SUDO="doas"
    else
        echo "error: $PREFIX is not writable and neither root nor sudo is available." >&2
        echo "       Install into your home instead:  ./install.sh --prefix=\$HOME/.local" >&2
        exit 1
    fi
}

# privileges for the package manager (independent of the install prefix)
pm_priv() {
    PM_SUDO="" PM_OK=1
    (( IS_TERMUX )) && return 0
    [[ "$(id -u)" -eq 0 ]] && return 0
    if have sudo; then PM_SUDO="sudo"
    elif have doas; then PM_SUDO="doas"
    else PM_OK=0; fi
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

run_pm() {
    if [[ $DRY -eq 1 ]]; then
        printf '  %s%s\n' "${PM_SUDO:+$PM_SUDO }" "$*"
    elif [[ -n "$PM_SUDO" ]]; then
        "$PM_SUDO" "$@"
    else
        "$@"
    fi
}

# ─── package manager detection (os-release first, PATH as fallback) ──
detect_pm() {
    local id="" id_like="" c="" osrelease
    if (( IS_TERMUX )); then
        have pkg && { echo pkg; return 0; }
        have apt-get && { echo apt-get; return 0; }
        echo ""; return 0
    fi
    (( IS_NIXOS )) && { echo ""; return 0; }
    osrelease="${WELLUTILS_OSRELEASE:-/etc/os-release}"
    if [[ -r "$osrelease" ]]; then
        id="$(. "$osrelease" 2>/dev/null; printf '%s' "${ID:-}")"
        id_like="$(. "$osrelease" 2>/dev/null; printf '%s' "${ID_LIKE:-}")"
    fi
    case "$id" in
        arch|manjaro|endeavouros|cachyos|artix|garuda|arcolinux) c=pacman ;;
        fedora|rhel|centos|rocky|almalinux|nobara|eurolinux|ol|oracle|amzn|anolis) c=dnf ;;
        debian|ubuntu|bodhi|linuxmint|pop|elementary|zorin|kali|mx|devuan|parrot|raspbian|astra|tuxedo|neon) c=apt-get ;;
        opensuse*|sles|sled)                     c=zypper ;;
        alpine|postmarketos|chainguard|wolfi)    c=apk ;;
        void)                                    c=xbps-install ;;
        gentoo|calculate|funtoo)                 c=emerge ;;
        solus)                                   c=eopkg ;;
        openwrt)                                 c=opkg ;;
        clear-linux-os)                          c=swupd ;;
        nixos|slackware)                         echo ""; return 0 ;;
    esac
    if [[ -z "$c" ]]; then
        case " $id_like " in
            *" arch "*)     c=pacman ;;
            *" fedora "*|*" rhel "*|*" centos "*) c=dnf ;;
            *" debian "*|*" ubuntu "*) c=apt-get ;;
            *" suse "*)     c=zypper ;;
        esac
    fi
    # CentOS 7 & co: dnf family without dnf -> yum
    [[ "$c" == dnf ]] && ! have dnf && have yum && c=yum
    if [[ -n "$c" ]] && have "$c"; then
        echo "$c"; return 0
    fi
    for c in pacman dnf yum apt-get zypper apk xbps-install emerge eopkg opkg swupd; do
        have "$c" && { echo "$c"; return 0; }
    done
    echo ""
}

os_label() {
    local f="${WELLUTILS_OSRELEASE:-/etc/os-release}"
    if (( IS_TERMUX )); then echo "Termux (Android)"; return; fi
    [[ -r "$f" ]] || { echo "unknown Linux"; return; }
    ( . "$f" 2>/dev/null; echo "${PRETTY_NAME:-${NAME:-unknown Linux}}" )
}

# ─── kernel / hardware detection ─────────────────────────────
detect_kernel() {
    uname -r 2>/dev/null || echo "unknown"
}

kernel_major() {
    local k="${1%%.*}"
    [[ "$k" =~ ^[0-9]+$ ]] && echo "$k" || echo ""
}

detect_hardware_profile() {
    local hw="generic" kmaj="${2:-}" dtmodel="" cnt=0 f
    if [[ -r /proc/device-tree/model ]]; then
        dtmodel=$(tr -d '\0' < /proc/device-tree/model 2>/dev/null || true)
        case "$dtmodel" in
            *Xbox*|*XBOX*|*xbox*) hw="xbox360" ;;
            *Raspberry*|*raspberry*) hw="rpi" ;;
            *BeagleBone*|*beaglebone*) hw="beaglebone" ;;
            *Apple*) hw="apple-silicon" ;;
            *Google*|*google*chromebook*) hw="chromebook" ;;
            ?*) hw="devicetree" ;;
        esac
    fi
    for f in /sys/class/thermal/cooling_device*; do [[ -e "$f" ]] && cnt=$((cnt + 1)); done
    (( cnt > 10 )) && hw="${hw}:embedded-thermal"
    if [[ -n "$kmaj" ]]; then
        if (( kmaj <= 2 )); then hw="${hw}:legacy-2.x"
        elif (( kmaj <= 3 )); then hw="${hw}:legacy-3.x"; fi
    fi
    if [[ -z "${DISPLAY:-}" && -z "${WAYLAND_DISPLAY:-}" ]]; then
        hw="${hw}:headless"
    fi
    echo "$hw"
}

detect_exotic_hardware() {
    local warnings=""
    [[ -d /proc/bus/usb ]] && warnings+="  note: /proc/bus/usb detected (legacy USB, kernel < 2.6.31)\n"
    [[ -d /sys/bus/isa ]] && warnings+="  note: ISA bus detected (legacy hardware)\n"
    [[ -d /sys/bus/pcmcia ]] && warnings+="  note: PCMCIA/CardBus detected\n"
    [[ -r /proc/xen/capabilities ]] && warnings+="  note: running in Xen domain\n"
    if grep -q "hypervisor" /proc/cpuinfo 2>/dev/null; then
        warnings+="  note: running in a virtual machine\n"
    fi
    if [[ -f /.dockerenv ]] || grep -q "docker" /proc/1/cgroup 2>/dev/null; then
        warnings+="  note: running inside a container\n"
    fi
    if uname -r 2>/dev/null | grep -qi microsoft; then
        warnings+="  note: running under WSL (Windows Subsystem for Linux)\n"
    fi
    (( IS_TERMUX )) && warnings+="  note: Termux: no root needed; some data (SMART, dmidecode) is unavailable\n"
    printf '%b' "$warnings"
}

# ─── dependencies ─────────────────────────────────────────────
pm_install() {
    [[ -n "$PM" ]] || return 1
    (( $# == 0 )) && return 0
    echo "==> $os: installing: $*"
    # One package at a time: a single unavailable name degrades to a
    # warning instead of aborting the whole transaction.
    local _rc=0 _p
    case "$PM" in
        apt-get)
            if [[ ! -d /var/lib/apt/lists ]] || [[ -z "$(ls -A /var/lib/apt/lists 2>/dev/null | grep -v '^lock$\|^partial$' || true)" ]]; then
                run_pm apt-get update || true
            fi ;;
        pkg) run_pm pkg update -y || true ;;
    esac
    for _p in "$@"; do
        case "$PM" in
            pacman)       run_pm pacman -S --noconfirm --needed "$_p" ;;
            dnf)          run_pm dnf install -y "$_p" ;;
            yum)          run_pm yum install -y "$_p" ;;
            apt-get)      run_pm apt-get install -y --no-install-recommends "$_p" ;;
            zypper)       run_pm zypper --non-interactive install "$_p" ;;
            apk)          run_pm apk add --no-cache "$_p" ;;
            xbps-install) run_pm xbps-install -Sy "$_p" ;;
            emerge)       run_pm emerge --noreplace "$_p" ;;
            eopkg)        run_pm eopkg install -y "$_p" ;;
            opkg)         run_pm opkg install "$_p" ;;
            swupd)        run_pm swupd bundle-add "$_p" ;;
            pkg)          run_pm pkg install -y "$_p" ;;
            *)            false ;;
        esac || { echo "    warning: package manager failed for: $_p" >&2; _rc=1; }
    done
    return "$_rc"
}

# Everything here is optional: the tools degrade gracefully without it.
# python is only used by whtml and the PNG logo of wellfetch.
deps_for() {
    case "$1" in
        pacman)        echo "bash coreutils util-linux procps-ng hwdata pciutils lm_sensors smartmontools dmidecode python" ;;
        dnf|yum)       echo "bash coreutils util-linux procps-ng hwdata pciutils lm_sensors smartmontools dmidecode python3" ;;
        apt-get)       echo "bash coreutils util-linux procps hwdata pciutils lm-sensors smartmontools dmidecode python3" ;;
        zypper)        echo "bash coreutils util-linux procps hwdata pciutils sensors smartmontools dmidecode python3" ;;
        apk)           echo "bash coreutils util-linux procps hwdata pciutils lm-sensors smartmontools dmidecode python3" ;;
        xbps-install)  echo "bash coreutils util-linux procps-ng hwids pciutils lm_sensors smartmontools dmidecode python3" ;;
        emerge)        echo "sys-apps/util-linux sys-process/procps sys-apps/hwdata sys-apps/pciutils sys-apps/lm-sensors sys-apps/smartmontools sys-apps/dmidecode dev-lang/python" ;;
        eopkg)         echo "bash coreutils util-linux procps-ng hwdata pciutils lm_sensors smartmontools dmidecode python3" ;;
        opkg)          echo "bash coreutils-sort pciutils usbutils" ;;
        swupd)         echo "sysadmin-basic python3-basic" ;;
        pkg)           echo "bash coreutils procps util-linux python" ;;
    esac
}

deps_hint() {
    if (( IS_NIXOS )); then
        echo "==> NixOS: dependencies are not installed imperatively. For a shell with them:"
        echo "      nix-shell -p pciutils usbutils lm_sensors smartmontools dmidecode python3"
    elif [[ -r /etc/slackware-version ]]; then
        echo "==> Slackware: install optional deps yourself (slackpkg install pciutils lm_sensors smartmontools dmidecode python3)"
    else
        echo "==> $os: no known package manager detected; installing files only"
        echo "    optional: pciutils, lm-sensors, smartmontools, dmidecode, hwdata, python3"
    fi
}

# ─── fetch sources (local checkout or GitHub tarball) ─────────
# Sets SRC (and _WU_INST_TMP when a download was needed). Not run in a
# subshell, so the EXIT trap lives in the main shell.
SRC=""
_WU_INST_TMP=""
acquire_source() {
    local here tag="" ref url tmpbase
    here="$(cd -- "$(dirname -- "$0")" 2>/dev/null && pwd || pwd)"
    if [[ "${WELLUTILS_LOCAL:-0}" == "1" || -t 0 ]] \
       && [[ -f "$here/src/wellmem" && -f "$here/src/lang.sh" && -f "$here/src/wellutils" ]]; then
        echo "==> using local checkout: $here" >&2
        SRC="$here"
        return 0
    fi

    if ! have curl && ! have wget; then
        echo "error: need curl or wget to download the source" >&2
        exit 1
    fi
    echo "==> downloading wellutils source from GitHub..." >&2
    tmpbase="${TMPDIR:-/tmp}"
    [[ -d "$tmpbase" && -w "$tmpbase" ]] || tmpbase="${_ENV_PREFIX:+$_ENV_PREFIX/tmp}"
    [[ -n "$tmpbase" && -d "$tmpbase" && -w "$tmpbase" ]] || tmpbase="${HOME:-.}"
    _WU_INST_TMP="$(mktemp -d "$tmpbase/wellutils-inst.XXXXXX")"
    trap '[[ -n "$_WU_INST_TMP" && -d "$_WU_INST_TMP" ]] && rm -rf -- "$_WU_INST_TMP"' EXIT

    ref="${WELLUTILS_REF:-}"
    if [[ -z "$ref" ]]; then
        # Prefer the newest tag over /releases/latest: a stale GitHub Release
        # can be much older than the repo.
        tag="$(fetch "$API/tags?per_page=100" - 2>/dev/null \
            | grep -o '"name"[[:space:]]*:[[:space:]]*"v[0-9][^"]*"' \
            | sed 's/.*:[[:space:]]*"//; s/"$//' | ver_max)" || tag=""
        ref="${tag:-main}"
    fi
    if [[ "$ref" == "main" || "$ref" == "master" ]]; then
        url="https://codeload.github.com/$REPO/tar.gz/refs/heads/$ref"
    else
        url="https://codeload.github.com/$REPO/tar.gz/refs/tags/$ref"
    fi
    echo "==> fetching ref: $ref" >&2
    fetch "$url" "$_WU_INST_TMP/wellutils.tar.gz" || { echo "error: download failed: $url" >&2; exit 1; }
    tar -xzf "$_WU_INST_TMP/wellutils.tar.gz" -C "$_WU_INST_TMP" || { echo "error: could not unpack the tarball" >&2; exit 1; }
    local e
    for e in "$_WU_INST_TMP"/*/; do
        [[ -d "$e" ]] && { SRC="${e%/}"; break; }
    done
    [[ -n "$SRC" ]] || SRC="$_WU_INST_TMP"
}

# ─── file lists (derived from the source tree, never hand-kept) ──
# Fill global arrays F_SRC / F_DST / F_MODE with every file to install.
F_SRC=() F_DST=() F_MODE=() L_SRC=() L_DST=()
add_file() { F_SRC+=("$1"); F_DST+=("$2"); F_MODE+=("$3"); }

collect_files() {
    local src="$1" f name first a base
    F_SRC=() F_DST=() F_MODE=() L_SRC=() L_DST=()
    local -a tools=()
    for f in "$src"/*; do
        [[ -f "$f" ]] || continue
        name="${f##*/}"
        [[ "$name" == *.* ]] && continue
        first=""
        IFS= read -r first < "$f" || true
        [[ "$first" == '#!'* ]] || continue
        tools+=("$name")
        add_file "$f" "$BINDIR/$name" 755
    done
    for f in "$src"/*.sh "$src"/wfetch_art.py "$src"/logo.png "$src"/VERSION; do
        [[ -f "$f" ]] && add_file "$f" "$LIBDIR/${f##*/}" 644
    done
    for f in "$src"/*.1; do
        [[ -f "$f" ]] && add_file "$f" "$MANDIR/${f##*/}" 644
    done
    [[ -f "$src/LICENSE" ]] && add_file "$src/LICENSE" "$LICDIR/LICENSE" 644
    for f in "$src"/*.bash; do
        [[ -f "$f" ]] || continue
        name="${f##*/}"
        add_file "$f" "$BASHCOMP/${name%.bash}" 644
    done
    for f in "$src"/completions/zsh/_*; do
        [[ -f "$f" ]] && add_file "$f" "$ZSHCOMP/${f##*/}" 644
    done
    for f in "$src"/completions/fish/*.fish; do
        [[ -f "$f" ]] && add_file "$f" "$FISHCOMP/${f##*/}" 644
    done
    for a in $ALIASES; do
        base="${a%%=*}"
        case " ${tools[*]-} " in
            *" $base "*) L_SRC+=("$base"); L_DST+=("$BINDIR/${a#*=}") ;;
        esac
    done
    (( ${#tools[@]} > 0 ))
}

# ─── install files ─────────────────────────────────────────────
do_install() {
    local src="$1" i fail=0 d
    echo "==> $os: installing wellutils to $PREFIX"
    need_root
    collect_files "$src" || { echo "error: no tools found under $src" >&2; return 1; }

    # remember what an earlier install left, to drop stale files afterwards
    local -a old=()
    if [[ -r "$MANIFEST" ]]; then
        while IFS= read -r d; do [[ -n "$d" ]] && old+=("$d"); done < "$MANIFEST"
    fi

    run install -d "$BINDIR" "$LIBDIR" "$MANDIR" "$BASHCOMP" "$ZSHCOMP" "$FISHCOMP" || return 1
    [[ -f "$src/LICENSE" ]] && { run install -d "$LICDIR" || fail=1; }
    for (( i=0; i<${#F_SRC[@]}; i++ )); do
        run install -m"${F_MODE[i]}" "${F_SRC[i]}" "${F_DST[i]}" \
            || { echo "error: could not install ${F_DST[i]}" >&2; fail=1; }
    done
    for (( i=0; i<${#L_SRC[@]}; i++ )); do
        # relative link: survives DESTDIR-style moves of the prefix
        run ln -sf "${L_SRC[i]}" "${L_DST[i]}" || { echo "error: could not link ${L_DST[i]}" >&2; fail=1; }
    done

    local -a new=()
    new=(${F_DST[@]+"${F_DST[@]}"} ${L_DST[@]+"${L_DST[@]}"} "$MANIFEST")
    # stale files from the previous install (e.g. completions that used to
    # go to /usr/share/...) -- only paths our own manifest recorded
    local o n keep
    for o in ${old[@]+"${old[@]}"}; do
        # Never touch anything outside our prefix: old releases wrote
        # completions to /usr/share/..., which may now belong to a distro
        # package (e.g. the pacman build of wellutils).
        [[ "$o" == "$PREFIX"/* ]] || continue
        keep=0
        for n in "${new[@]}"; do [[ "$o" == "$n" ]] && { keep=1; break; }; done
        (( keep )) || { [[ -e "$o" || -L "$o" ]] && run rm -f "$o"; } || true
    done

    if [[ $DRY -eq 1 ]]; then
        printf '  write manifest %s (%d entries)\n' "$MANIFEST" "${#new[@]}"
    else
        printf '%s\n' "${new[@]}" | run tee "$MANIFEST" >/dev/null \
            || echo "    warning: could not write $MANIFEST" >&2
    fi

    (( fail )) && { echo "error: one or more files could not be written" >&2; return 1; }
    return 0
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
    local f
    while IFS= read -r f; do
        [[ -n "$f" && "$f" != "$MANIFEST" ]] || continue
        [[ -e "$f" || -L "$f" ]] || continue
        run rm -f "$f" || echo "    warning: could not remove $f" >&2
    done < "$MANIFEST"
    run rm -f "$MANIFEST" || true
    # remove directories only when they ended up empty
    local d
    for d in "$LIBDIR" "$LICDIR" "$PREFIX/share/licenses" "$MANDIR" "$PREFIX/share/man" \
             "$BASHCOMP" "$PREFIX/share/bash-completion" "$ZSHCOMP" "$PREFIX/share/zsh" \
             "$FISHCOMP" "$PREFIX/share/fish" "$PREFIX/share" "$BINDIR" "$PREFIX"; do
        if [[ $DRY -eq 1 ]]; then
            printf '  rmdir %s (if empty)\n' "$d"
        elif [[ -d "$d" ]]; then
            $SUDO rmdir "$d" 2>/dev/null || true
        fi
    done
}

# ─── main ─────────────────────────────────────────────────────
if [[ "$(uname -s 2>/dev/null)" == "Darwin" ]]; then
    echo "error: macOS is not supported: wellutils reads Linux /proc and /sys." >&2
    exit 1
fi

while (( $# > 0 )); do
    arg="$1"
    case "$arg" in
        --help|-h)     usage; exit 0 ;;
        --no-deps)     DO_DEPS=0 ;;
        --deps-only)   DO_FILES=0 ;;
        --uninstall)   UNINSTALL=1 ;;
        --dry-run)     DRY=1 ;;
        --hardware)    _kver="$(detect_kernel)"; _kmaj="$(kernel_major "$_kver")"; echo "kernel: $_kver"; echo "profile: $(detect_hardware_profile "$_kver" "$_kmaj")"; detect_exotic_hardware; exit 0 ;;
        --prefix=*)    PREFIX="${arg#*=}" ;;
        --prefix)      [[ $# -ge 2 ]] || { echo "error: --prefix needs a path" >&2; exit 2; }; PREFIX="$2"; shift ;;
        *) echo "error: unknown option: $arg" >&2; usage >&2; exit 2 ;;
    esac
    shift
done
[[ -n "$PREFIX" ]] || { echo "error: empty --prefix" >&2; exit 2; }
[[ "$PREFIX" == /* ]] || PREFIX="$(pwd)/$PREFIX"
PREFIX="${PREFIX%/}"; [[ -n "$PREFIX" ]] || PREFIX="/"
set_paths

os="$(os_label)"
PM="$(detect_pm)"
_kver="$(detect_kernel)"
_kmaj="$(kernel_major "$_kver")"
_hwprof="$(detect_hardware_profile "$_kver" "$_kmaj")"

echo "==> $os"
echo "    kernel:   $_kver"
[[ "$_hwprof" != "generic" ]] && echo "    hardware: $_hwprof"
_exotic="$(detect_exotic_hardware)"
[[ -n "$_exotic" ]] && printf '%s\n' "$_exotic"

if [[ $UNINSTALL -eq 1 ]]; then
    do_uninstall
    exit 0
fi

if [[ $DO_DEPS -eq 1 ]]; then
    if [[ -n "$PM" ]]; then
        pm_priv
        if (( PM_OK )); then
            echo "==> $os: package manager: $PM"
            read -r -a pkgs <<< "$(deps_for "$PM")"
            pm_install ${pkgs[@]+"${pkgs[@]}"} || echo "    warning: dependency install reported a problem (continuing anyway)"
        else
            echo "==> not root and no sudo: skipping optional dependencies ($PM)"
            echo "    (run as root later, or ignore: the tools degrade gracefully)"
        fi
    else
        deps_hint
    fi
fi

if [[ $DO_FILES -eq 0 ]]; then
    echo "==> dependencies done (--deps-only)."
    exit 0
fi

acquire_source
# Tolerate both the src/ layout and legacy flat tarballs.
if [[ -d "$SRC/src" ]]; then
    SRC_W="$SRC/src"
else
    SRC_W="$SRC"
fi
do_install "$SRC_W" || {
    echo
    echo "==> FAILED: some files could not be installed (see errors above)." >&2
    exit 2
}

echo
if [[ $DRY -eq 1 ]]; then
    echo "==> dry run: nothing was changed."
else
    echo "==> wellutils installed."
fi
echo "    version:   $(cat "$SRC_W/VERSION" 2>/dev/null || echo '?')"
echo "    binaries:  $BINDIR"
echo "    data:      $LIBDIR"
echo "    man:       $MANDIR"
case ":${PATH:-}:" in
    *":$BINDIR:"*) echo '    try:       wellfetch | wellmem | wellusb | wellhw' ;;
    *) echo "    note:      $BINDIR is not in PATH; add:  export PATH=\"$BINDIR:\$PATH\"" ;;
esac
if (( IS_NIXOS )); then
    echo "    NixOS:     ~/.local/bin must be in PATH (home-manager: home.sessionPath)"
fi
