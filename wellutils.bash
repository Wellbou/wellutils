# bash completion for wellutils
# Part of wellutils by wellbou_

_wellutils() {
    local cur subcmds
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    subcmds="usb pci block mem mod sensors hw per gpu cpu fetch up net power doctor self-update --help --version --lang --color --plain --box --no-emoji --json --debug --"
    COMPREPLY=( $(compgen -W "$subcmds" -- "$cur") )
    return 0
}
complete -F _wellutils wellutils
