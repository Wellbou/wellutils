# distro_art.sh -- ASCII logos for wellfetch, keyed by os-release ID.
# Plain text only (no ANSI): the box renderer measures visible width.
# Part of wellutils by wellbou_

wf_distro_art() {
    local id="" id_like="" line f
    # Same lookup order as wu_os_pretty: override, /etc, /usr/lib, Termux.
    for f in "${WF_OSFILE:-}" /etc/os-release /usr/lib/os-release "${PREFIX:-/nonexistent}/etc/os-release"; do
        [[ -n "$f" && -r "$f" ]] || continue
        while IFS= read -r line || [[ -n "$line" ]]; do
            case "$line" in
                ID=*) id="${line#ID=}" ;;
                ID_LIKE=*) id_like="${line#ID_LIKE=}" ;;
            esac
        done < "$f"
        break
    done
    id="${id//\"/}"; id="${id//\'/}"; id="${id%$'\r'}"; id="${id,,}"
    id_like="${id_like//\"/}"; id_like="${id_like//\'/}"; id_like="${id_like%$'\r'}"; id_like="${id_like,,}"
    case "${id:-}" in
        arch|archarm|artix)
            cat <<'ART'
       /\
      /  \
     /\   \
    /  __  \
   /  (  )  \
  / __|  |__ \
 /.`        `.\
ART
            ;;
        cachyos)
            cat <<'ART'
     /\
    /  \
   /    \
  /  ,,  \
 /   ||   \
/___||___\
   CachyOS
ART
            ;;
        endeavouros)
            cat <<'ART'
        /\
       /\/\
      /\/\/\
     /  \/  \
    / , ` ,  \
   /  ` -- `  \
ART
            ;;
        manjaro)
            cat <<'ART'
  __  ____ _____ _____
  \ \ \  _ \  _ \  _ \
   \ \ \ \\ \ \\ \ \\ \
    \_\ \_\ \_\ \_\ \_\
ART
            ;;
        garuda)
            cat <<'ART'
      /\
     /  \
    / /\ \
   / /  \ \
  / / /\ \ \
 /_/ /  \ \_\
ART
            ;;
        debian)
            cat <<'ART'
      _,met$$$$$gg.
   ,g$$$$$$$$$$$$$$$P.
 ,g$$P""       """Y$$.".
,$$P'              `$$$.
'$$P       ,ggs.     `$$b:
`d$$'     ,$P"'   .    $$$
 $$P      d$'     ,    $$P
 $$:      $$.   -    ,d$$'
ART
            ;;
        ubuntu)
            cat <<'ART'
          _
     ---(_)
 _/  ---  \
(_) |   |
  \  --- _/
     ---(_)
ART
            ;;
        linuxmint|mint)
            cat <<'ART'
  _____  ___  ____
 |_   _|_ _||  _ \
   | |  | | | |_) |
   |_| |___||  __/
           |_|
ART
            ;;
        fedora)
            cat <<'ART'
       ,'''''.
      |   ,.  |
      |  |  '_'
   ,..|   '.
 ,'        `.
ART
            ;;
        opensuse*|suse)
            cat <<'ART'
   .;ldkO00000Okdl;.
 OXkc,.       .,cKO
 Kd.   .;dOOxl.  .dK
 K   lO0KKKKK0Ol.  K
 K  OKKKKKKKKKKKO. K
 K  OKKKKKKKKKKKKO,K
ART
            ;;
        alpine)
            cat <<'ART'
      .hddddddddddddddddddddddh.
     :dddddddddddddddddddddddddd:
    :ddddd oNNNNNNNNNNNNNNN dddd:
   :ddddd NNNNNNNNNNNNNNNNN dddd:
ART
            ;;
        void)
            cat <<'ART'
       _______
    _ \______ -
   | \  ___  \ |
   | | /   \ | |
   | | \___/ | |
   |_ \______\_|_
ART
            ;;
        gentoo)
            cat <<'ART'
     -/oyddmdhs+:.
 -o dNMMMMMMMMNNmhy+-`
 yNMMMMMMMMMMMNNNmms+"
 / mMMMMMMMMMMMNNmnmy+
OMMMMMMMMMMMMNmnmmo
ART
            ;;
        nixos|nix)
            cat <<'ART'
   ▗▄▄▄  ▗▄▄▄▖ ▗▄▄ ▗▄▄
   █ █ █ █    █  █ █
   █ █ █ ▝▀▀▀▘ █    █
   █ █ █ ▗▄▄▄▖ █    █
ART
            ;;
        pop)
            cat <<'ART'
 /////////////
 /*         */
 /*    ^   */
 /*  /  \  */
 /*  \  /  */
 /*    v   */
ART
            ;;
        kali)
            cat <<'ART'
..............
 ..,;,,,,,,,;
 ..,,,,,,,,
 ..,,,,,,,,,,
 ;,,,,,,,;;
ART
            ;;
        centos|rocky|almalinux|alma|rhel|ol)
            cat <<'ART'
  ____ _____  _  _____
 / ___|_   _|/ \|_   _|
| |     | | / _ \ | |
| |___  |/ ___ \| |
 \____|/_/   \_\_|
ART
            ;;
        elementary*)
            cat <<'ART'
    eeeeeeeeeeeeeeeeeeee
 eeeeee eeeeeeeee eeeeee
eeeeee ee ee ee ee eeeeee
ART
            ;;
        slackware)
            cat <<'ART'
   ______  ______ ______
  / __/ / / / __// __ /
 _\ \/ /_/ /\ \_/ /_/
/___/\____/ \___\_\
ART
            ;;
        raspbian|raspios)
            cat <<'ART'
  .~~.   .~~.
 '. \ ' ' / .'
  .~.'~~~'.~.
 : .'  ~  '. :
ART
            ;;
        *)
            # Fall back on ID_LIKE (a space separated list) for derivatives.
            case " ${id_like} " in
                *" arch "*)
                    cat <<'ART'
       /\
      /  \
     /\   \
    /  __  \
   /  (  )  \
  / __|  |__ \
ART
                    ;;
                *" debian "*|*" ubuntu "*)
                    cat <<'ART'
      _,met$$$$$gg.
   ,g$$$$$$$$$$$$$$$P.
 ,g$$P""       """Y$$.".
,$$P'              `$$$.
'$$P       ,ggs.     `$$b:
ART
                    ;;
                *" fedora "*|*" rhel "*|*" centos "*)
                    cat <<'ART'
       ,'''''.
      |   ,.  |
      |  |  '_'
   ,..|   '.
 ,'        `.
ART
                    ;;
                *" suse "*|*" opensuse "*)
                    cat <<'ART'
   .;ldkO00000Okdl;.
 OXkc,.       .,cKO
 Kd.   .;dOOxl.  .dK
 K   lO0KKKKK0Ol.  K
ART
                    ;;
                *" gentoo "*)
                    cat <<'ART'
     -/oyddmdhs+:.
 -o dNMMMMMMMMNNmhy+-`
 yNMMMMMMMMMMMNNNmms+"
OMMMMMMMMMMMMNmnmmo
ART
                    ;;
                *)
                    # Generic Tux: every Linux gets a logo (Termux, BusyBox,
                    # embedded images without os-release, unknown distros).
                    cat <<'ART'
    .--.
   |o_o |
   |:_/ |
  //   \ \
 (|     | )
/'\_   _/`\
\___)=(___/
ART
                    ;;
            esac ;;
    esac
    return 0
}
