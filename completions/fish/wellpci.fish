# fish completion for wellpci
# Part of wellutils by wellbou_

complete -c wellpci -f
complete -c wellpci -s h -l help -d 'show help'
complete -c wellpci -l version -d 'show version'
complete -c wellpci -l lang -x -a 'ru en auto' -d 'output language'
complete -c wellpci -l color -x -a 'always auto never' -d 'colorize output'
complete -c wellpci -l --all -d "all"
complete -c wellpci -l --json -d "json"
complete -c wellpci -l --short -d "short"
complete -c wellpci -l --html -d "html"
complete -c wellpci -l --plain -d "plain"
complete -c wellpci -l --box -d "box"
complete -c wellpci -l --no-emoji -d "no-emoji"
complete -c wellpci -l --emoji -d "emoji"
complete -c wellpci -l debug -d "shell tracing"
