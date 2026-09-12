# fish completion for wellmod
# Part of wellutils by wellbou_

complete -c wellmod -f
complete -c wellmod -s h -l help -d 'show help'
complete -c wellmod -l version -d 'show version'
complete -c wellmod -l lang -x -a 'ru en auto' -d 'output language'
complete -c wellmod -l color -x -a 'always auto never' -d 'colorize output'
complete -c wellmod -l --deps -d "deps"
complete -c wellmod -l --filter -d "filter"
complete -c wellmod -l --json -d "json"
complete -c wellmod -l --short -d "short"
complete -c wellmod -l --html -d "html"
complete -c wellmod -l --plain -d "plain"
complete -c wellmod -l --box -d "box"
complete -c wellmod -l --no-emoji -d "no-emoji"
complete -c wellmod -l --emoji -d "emoji"
complete -c wellmod -l debug -d "shell tracing"
