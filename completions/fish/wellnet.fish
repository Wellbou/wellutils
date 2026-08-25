# fish completion for wellnet
# Part of wellutils by wellbou_

complete -c wellnet -f
complete -c wellnet -s h -l help -d 'show help'
complete -c wellnet -l version -d 'show version'
complete -c wellnet -l lang -x -a 'ru en auto' -d 'output language'
complete -c wellnet -l color -x -a 'always auto never' -d 'colorize output'
complete -c wellnet -l --json -d "json"
complete -c wellnet -l --short -d "short"
complete -c wellnet -l --html -d "html"
complete -c wellnet -l --plain -d "plain"
complete -c wellnet -l --box -d "box"
complete -c wellnet -l --no-emoji -d "no-emoji"
complete -c wellnet -l --emoji -d "emoji"
complete -c wellnet -l debug -d "shell tracing"
