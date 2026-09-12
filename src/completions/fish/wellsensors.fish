# fish completion for wellsensors
# Part of wellutils by wellbou_

complete -c wellsensors -f
complete -c wellsensors -s h -l help -d 'show help'
complete -c wellsensors -l version -d 'show version'
complete -c wellsensors -l lang -x -a 'ru en auto' -d 'output language'
complete -c wellsensors -l color -x -a 'always auto never' -d 'colorize output'
complete -c wellsensors -l --watch -d "watch"
complete -c wellsensors -l --interval -d "interval"
complete -c wellsensors -l --sections -d "sections"
complete -c wellsensors -l --json -d "json"
complete -c wellsensors -l --short -d "short"
complete -c wellsensors -l --html -d "html"
complete -c wellsensors -l --plain -d "plain"
complete -c wellsensors -l --box -d "box"
complete -c wellsensors -l --no-emoji -d "no-emoji"
complete -c wellsensors -l --emoji -d "emoji"
complete -c wellsensors -l debug -d "shell tracing"
