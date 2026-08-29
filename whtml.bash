# bash completion for whtml
# Part of wellutils by wellbou_

_whtml() {
    local cur prev
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    local opts="--help -h --version -V --output --output= --open --no-open --ai --no-ai --lang --lang= --debug --"

    case "$prev" in
        --output)
            COMPREPLY=( $(compgen -f -- "$cur") )
            return 0
            ;;
        --output=*)
            COMPREPLY=( $(compgen -f -- "${cur#*=}") )
            return 0
            ;;
        --lang|-l)
            COMPREPLY=( $(compgen -W "ru en auto" -- "$cur") )
            return 0
            ;;
    esac

    case "$cur" in
        --*)
            COMPREPLY=( $(compgen -W "$opts" -- "$cur") )
            return 0
            ;;
    esac

    return 0
}

complete -F _whtml whtml
