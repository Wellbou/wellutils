# fish completion for wellfetch
# Part of wellutils by wellbou_

complete -c wellfetch -f
complete -c wellfetch -s h -l help -d 'show help'
complete -c wellfetch -l version -d 'show version'
complete -c wellfetch -l lang -x -a 'ru en auto' -d 'output language'
complete -c wellfetch -l color -x -a 'always auto never' -d 'colorize output'
complete -c wellfetch -l --logo -d "logo"
complete -c wellfetch -l --no-logo -d "no-logo"
complete -c wellfetch -l --png -d "png"
complete -c wellfetch -l --logo-width -d "logo-width"
complete -c wellfetch -l --key -d "key"
complete -c wellfetch -l --custom -d "custom"
complete -c wellfetch -l --all -d "all"
complete -c wellfetch -l --full -d "full"
complete -c wellfetch -l --json -d "json"
complete -c wellfetch -l --short -d "short"
complete -c wellfetch -l --html -d "html"
complete -c wellfetch -l --plain -d "plain"
complete -c wellfetch -l --box -d "box"
complete -c wellfetch -l --no-emoji -d "no-emoji"
complete -c wellfetch -l --emoji -d "emoji"
complete -c wellfetch -l debug -d "shell tracing"
