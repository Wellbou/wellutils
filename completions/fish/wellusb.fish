# fish completion for wellusb
# Part of wellutils by wellbou_

complete -c wellusb -f
complete -c wellusb -s h -l help -d 'show help'
complete -c wellusb -l version -d 'show version'
complete -c wellusb -l lang -x -a 'ru en auto' -d 'output language'
complete -c wellusb -l color -x -a 'always auto never' -d 'colorize output'
complete -c wellusb -l --json -d "json"
complete -c wellusb -l --short -d "short"
complete -c wellusb -l --html -d "html"
complete -c wellusb -l --plain -d "plain"
complete -c wellusb -l --box -d "box"
complete -c wellusb -l --no-emoji -d "no-emoji"
complete -c wellusb -l --emoji -d "emoji"
complete -c wellusb -l debug -d "shell tracing"
