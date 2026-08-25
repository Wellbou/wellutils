# fish completion for welldoctor
# Part of wellutils by wellbou_

complete -c welldoctor -f
complete -c welldoctor -s h -l help -d 'show help'
complete -c welldoctor -l version -d 'show version'
complete -c welldoctor -l lang -x -a 'ru en auto' -d 'output language'
complete -c welldoctor -l color -x -a 'always auto never' -d 'colorize output'
complete -c welldoctor -l --json -d "json"
complete -c welldoctor -l --short -d "short"
complete -c welldoctor -l --html -d "html"
complete -c welldoctor -l --plain -d "plain"
complete -c welldoctor -l --box -d "box"
complete -c welldoctor -l --no-emoji -d "no-emoji"
complete -c welldoctor -l --emoji -d "emoji"
complete -c welldoctor -l debug -d "shell tracing"
