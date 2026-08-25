# fish completion for wellcpu
# Part of wellutils by wellbou_

complete -c wellcpu -f
complete -c wellcpu -s h -l help -d 'show help'
complete -c wellcpu -l version -d 'show version'
complete -c wellcpu -l lang -x -a 'ru en auto' -d 'output language'
complete -c wellcpu -l color -x -a 'always auto never' -d 'colorize output'
complete -c wellcpu -l --json -d "json"
complete -c wellcpu -l --short -d "short"
complete -c wellcpu -l --html -d "html"
complete -c wellcpu -l --plain -d "plain"
complete -c wellcpu -l --box -d "box"
complete -c wellcpu -l --no-emoji -d "no-emoji"
complete -c wellcpu -l --emoji -d "emoji"
complete -c wellcpu -l debug -d "shell tracing"
