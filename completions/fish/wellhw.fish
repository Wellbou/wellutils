# fish completion for wellhw
# Part of wellutils by wellbou_

complete -c wellhw -f
complete -c wellhw -s h -l help -d 'show help'
complete -c wellhw -l version -d 'show version'
complete -c wellhw -l lang -x -a 'ru en auto' -d 'output language'
complete -c wellhw -l color -x -a 'always auto never' -d 'colorize output'
complete -c wellhw -l --snapshot -d "snapshot"
complete -c wellhw -l --diff -d "diff"
complete -c wellhw -l --json -d "json"
complete -c wellhw -l --short -d "short"
complete -c wellhw -l --html -d "html"
complete -c wellhw -l --plain -d "plain"
complete -c wellhw -l --box -d "box"
complete -c wellhw -l --no-emoji -d "no-emoji"
complete -c wellhw -l --emoji -d "emoji"
complete -c wellhw -l debug -d "shell tracing"
