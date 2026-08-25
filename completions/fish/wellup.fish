# fish completion for wellup
# Part of wellutils by wellbou_

complete -c wellup -f
complete -c wellup -s h -l help -d 'show help'
complete -c wellup -l version -d 'show version'
complete -c wellup -l lang -x -a 'ru en auto' -d 'output language'
complete -c wellup -l color -x -a 'always auto never' -d 'colorize output'
complete -c wellup -l --check -d "check"
complete -c wellup -l --list -d "list"
complete -c wellup -l --yes -d "yes"
complete -c wellup -l --pacnew -d "pacnew"
complete -c wellup -l --self-update -d "self-update"
complete -c wellup -l --self -d "self"
complete -c wellup -l --json -d "json"
complete -c wellup -l --short -d "short"
complete -c wellup -l --html -d "html"
complete -c wellup -l --plain -d "plain"
complete -c wellup -l --box -d "box"
complete -c wellup -l --no-emoji -d "no-emoji"
complete -c wellup -l --emoji -d "emoji"
complete -c wellup -l debug -d "shell tracing"
