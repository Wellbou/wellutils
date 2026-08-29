# fish completion for whtml
# Part of wellutils by wellbou_

complete -c whtml -f
complete -c whtml -s h -l help -d 'show help'
complete -c whtml -s V -l version -d 'show version'
complete -c whtml -l output -r -d 'save HTML to file'
complete -c whtml -l open -d 'force open in browser'
complete -c whtml -l no-open -d 'do not auto-open in browser'
complete -c whtml -l ai -d 'optional AI analysis (needs WHTML_AI_ENDPOINT)'
complete -c whtml -l no-ai -d 'disable AI'
complete -c whtml -l lang -x -a 'ru en auto' -d 'output language'
complete -c whtml -l debug -d 'verbose on stderr (WHTML_DEBUG=1)'
