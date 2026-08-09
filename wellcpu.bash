# bash completion for wellcpu
# Part of wellutils by wellbou_

_wellcpu() {
    local cur prev
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    local opts="--help -h --version -V --lang --color --plain --box --no-emoji --debug --"

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

    return 0
}

complete -F _wellcpu wellcpu
complete -F _wellcpu wcpu
