#!/usr/bin/env bash
# gen-completions.sh -- generate bash/zsh/fish completions for all wellutils
# tools from one flag table. Run from the repo root:  tools/gen-completions.sh
set -euo pipefail
cd "$(dirname "$0")/.."

# tool|name|extra flags (space separated, may be empty)
TABLE='
wellusb|WellUSB|--json --plain --box --no-emoji --emoji
wellpci|WellPCI|--all --json --plain --box --no-emoji --emoji
wellblock|WellBlock|--json --smart --dump --all --plain --box --no-emoji --emoji
wellmem|WellMem|--json --short --html --plain --box --no-emoji --emoji
wellmod|WellMod|--deps --filter --json --plain --box --no-emoji --emoji
wellsensors|WellSensors|--watch --interval --sections --json --short --html --plain --box --no-emoji --emoji
wellhw|WellHW|--json --snapshot --diff --html --plain --box --no-emoji --emoji
wellper|WellPer|--groups --sections --terse --strict --json --plain --box --no-emoji --emoji
wellgpu|WellGPU|--json --short --plain --box --no-emoji --emoji
wellcpu|WellCPU|--json --short --html --plain --box --no-emoji --emoji
wellfetch|WellFetch|--logo --no-logo --png --logo-width --key --custom --all --full --json --short --html --plain --box --no-emoji --emoji
wellup|WellUp|--check --list --yes --pacnew --self-update --self --json --short --html --plain --box --no-emoji --emoji
wellnet|WellNet|--json --short --html --plain --box --no-emoji --emoji
wellpower|WellPower|--json --short --html --plain --box --no-emoji --emoji
welldoctor|WellDoctor|--json --html --plain --box --no-emoji --emoji
'

gen_bash() {
    local tool="$1" opts="$2"
    cat <<EOF
# bash completion for $tool
# Part of wellutils by wellbou_

_$tool() {
    local cur prev
    COMPREPLY=()
    cur="\${COMP_WORDS[COMP_CWORD]}"
    prev="\${COMP_WORDS[COMP_CWORD-1]}"

    local opts="--help -h --version -V --lang --lang= --color --color= $opts --debug --"

    case "\$prev" in
        --lang|-l)
            COMPREPLY=( \$(compgen -W "ru en auto" -- "\$cur") )
            return 0
            ;;
        --color)
            COMPREPLY=( \$(compgen -W "always never auto" -- "\$cur") )
            return 0
            ;;
    esac

    case "\$cur" in
        -*)
            COMPREPLY=( \$(compgen -W "\$opts" -- "\$cur") )
            return 0
            ;;
    esac

    return 0
}

complete -F _$tool $tool
EOF
}

gen_zsh() {
    local tool="$1" name="$2" extra="$3"
    local args="--help[show help] --version[show version] --lang=[output language]: :(ru en auto) --color=[colorize output]: :(always auto never)"
    local o
    for o in $extra; do
        args+=" ${o%%=*}[]"
    done
    args+=" --debug[shell tracing] --"
    cat <<EOF
#compdef $tool
# zsh completion for $tool
# Part of wellutils by wellbou_

_${tool}() {
    _arguments -S \\
        $(printf '%s' "$args" | sed 's/ --/ \\\n        --/g')
}

_$tool "\$@"
EOF
}

gen_fish() {
    local tool="$1" name="$2" extra="$3"
    cat <<EOF
# fish completion for $tool
# Part of wellutils by wellbou_

complete -c $tool -f
complete -c $tool -s h -l help -d 'show help'
complete -c $tool -l version -d 'show version'
complete -c $tool -l lang -x -a 'ru en auto' -d 'output language'
complete -c $tool -l color -x -a 'always auto never' -d 'colorize output'
EOF
    local o
    for o in $extra; do
        printf 'complete -c %s -l %s -d "%s"\n' "$tool" "${o%%=*}" "${o#--}" | sed 's/ -d "--/ -d "/'
    done
    printf 'complete -c %s -l debug -d "shell tracing"\n' "$tool"
}

mkdir -p completions/zsh completions/fish
while IFS='|' read -r tool name extra; do
    [[ -z "$tool" || "$tool" == \#* ]] && continue
    base_opts="--json --short --html --plain --box --no-emoji --emoji"
    # avoid duplicates already listed in the table row
    row_opts=""
    for o in $extra; do
        case " $base_opts " in *" $o "*) ;; *) row_opts+="$o " ;; esac
    done
    all="$row_opts$base_opts"
    gen_bash  "$tool" "$all"   > "$tool.bash"
    gen_zsh   "$tool" "$name" "$all" > "completions/zsh/_$tool"
    gen_fish  "$tool" "$name" "$all" > "completions/fish/$tool.fish"
    echo "generated: $tool (.bash, zsh, fish)"
done <<< "$TABLE"

# launcher completion lists subcommands
cat > wellutils.bash <<'EOF'
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
EOF
echo "generated: wellutils (.bash)"
