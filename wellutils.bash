# bash completion for wellutils launcher
# Part of wellutils by wellbou_

_wellutils() {
    local cur prev
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    local tools="wellper wellhw wellmem wellsensors wellusb wellpci wellblock wellmod"
    local aliases="per hw mem sensors usb pci block mod wper whw wmem wsensors wtemp wusb wpci wblock wmod"
    local opts="--lang -l --help -h --version -V"

    case "$prev" in
        --lang|-l)
            COMPREPLY=( $(compgen -W "ru en eng RU EN ENG" -- "$cur") )
            return 0
            ;;
    esac

    case "$cur" in
        -*)
            COMPREPLY=( $(compgen -W "$opts" -- "$cur") )
            return 0
            ;;
        *)
            COMPREPLY=( $(compgen -W "$tools $aliases" -- "$cur") )
            return 0
            ;;
    esac
}

complete -F _wellutils wellutils
