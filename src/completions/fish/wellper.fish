# fish completion for wellper
# Part of wellutils by wellbou_

complete -c wellper -f
complete -c wellper -s h -l help -d 'show help'
complete -c wellper -l version -d 'show version'
complete -c wellper -l lang -x -a 'ru en auto' -d 'output language'
complete -c wellper -l color -x -a 'always auto never' -d 'colorize output'
complete -c wellper -l --groups -d "groups"
complete -c wellper -l --sections -d "sections"
complete -c wellper -l --terse -d "terse"
complete -c wellper -l --strict -d "strict"
complete -c wellper -l --json -d "json"
complete -c wellper -l --short -d "short"
complete -c wellper -l --html -d "html"
complete -c wellper -l --plain -d "plain"
complete -c wellper -l --box -d "box"
complete -c wellper -l --no-emoji -d "no-emoji"
complete -c wellper -l --emoji -d "emoji"
complete -c wellper -l debug -d "shell tracing"
