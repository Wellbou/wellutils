# fish completion for wellgpu
# Part of wellutils by wellbou_

complete -c wellgpu -f
complete -c wellgpu -s h -l help -d 'show help'
complete -c wellgpu -l version -d 'show version'
complete -c wellgpu -l lang -x -a 'ru en auto' -d 'output language'
complete -c wellgpu -l color -x -a 'always auto never' -d 'colorize output'
complete -c wellgpu -l --json -d "json"
complete -c wellgpu -l --short -d "short"
complete -c wellgpu -l --html -d "html"
complete -c wellgpu -l --plain -d "plain"
complete -c wellgpu -l --box -d "box"
complete -c wellgpu -l --no-emoji -d "no-emoji"
complete -c wellgpu -l --emoji -d "emoji"
complete -c wellgpu -l debug -d "shell tracing"
