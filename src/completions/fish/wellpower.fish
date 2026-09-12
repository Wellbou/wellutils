# fish completion for wellpower
# Part of wellutils by wellbou_

complete -c wellpower -f
complete -c wellpower -s h -l help -d 'show help'
complete -c wellpower -l version -d 'show version'
complete -c wellpower -l lang -x -a 'ru en auto' -d 'output language'
complete -c wellpower -l color -x -a 'always auto never' -d 'colorize output'
complete -c wellpower -l --json -d "json"
complete -c wellpower -l --short -d "short"
complete -c wellpower -l --html -d "html"
complete -c wellpower -l --plain -d "plain"
complete -c wellpower -l --box -d "box"
complete -c wellpower -l --no-emoji -d "no-emoji"
complete -c wellpower -l --emoji -d "emoji"
complete -c wellpower -l debug -d "shell tracing"
