# fish completion for wellblock
# Part of wellutils by wellbou_

complete -c wellblock -f
complete -c wellblock -s h -l help -d 'show help'
complete -c wellblock -l version -d 'show version'
complete -c wellblock -l lang -x -a 'ru en auto' -d 'output language'
complete -c wellblock -l color -x -a 'always auto never' -d 'colorize output'
complete -c wellblock -l --smart -d "smart"
complete -c wellblock -l --dump -d "dump"
complete -c wellblock -l --all -d "all"
complete -c wellblock -l --json -d "json"
complete -c wellblock -l --short -d "short"
complete -c wellblock -l --html -d "html"
complete -c wellblock -l --plain -d "plain"
complete -c wellblock -l --box -d "box"
complete -c wellblock -l --no-emoji -d "no-emoji"
complete -c wellblock -l --emoji -d "emoji"
complete -c wellblock -l debug -d "shell tracing"
