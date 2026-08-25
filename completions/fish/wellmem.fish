# fish completion for wellmem
# Part of wellutils by wellbou_

complete -c wellmem -f
complete -c wellmem -s h -l help -d 'show help'
complete -c wellmem -l version -d 'show version'
complete -c wellmem -l lang -x -a 'ru en auto' -d 'output language'
complete -c wellmem -l color -x -a 'always auto never' -d 'colorize output'
complete -c wellmem -l --json -d "json"
complete -c wellmem -l --short -d "short"
complete -c wellmem -l --html -d "html"
complete -c wellmem -l --plain -d "plain"
complete -c wellmem -l --box -d "box"
complete -c wellmem -l --no-emoji -d "no-emoji"
complete -c wellmem -l --emoji -d "emoji"
complete -c wellmem -l debug -d "shell tracing"
