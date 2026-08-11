# bash completion for wellblock
# Part of wellutils by wellbou_

_wellblock() {
    local cur prev
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    local opts="--help -h --version -V --lang --color --plain --box --no-emoji --json --debug --"

    case "$prev" in
        --lang|-l)
            COMPREPLY=( $(compgen -W "ru en auto" -- "$cur") )
            return 0
            ;;
        --color)
            COMPREPLY=( $(compgen -W "always never auto" -- "$cur") )
            return 0
            ;;
    esac

    case "$cur" in
        -*)
            COMPREPLY=( $(compgen -W "$opts" -- "$cur") )
            return 0
            ;;
    esac

    COMPREPLY=( $(compgen -W "$(ls /sys/block/ 2>/dev/null)" -- "$cur") )
    return 0
}

complete -F _wellblock wellblock
complete -F _wellblock wblock
