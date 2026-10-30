function rex-sessions -d "fzf picker over Rex sessions, previewing their tabs (Rex cmd+o)"
    set -l client $argv[1]
    set -l current $argv[2]
    set -l lines (rex ls --json | jq -r --arg c $current '.sessions[] |
        "\(if .session_id == $c then "● " else "  " end)\(.label)\t\(.session_id)"')
    set -l pick (printf '%s\n' $lines | fzf --ansi --cycle --highlight-line --reverse --no-sort \
        --delimiter \t --with-nth 1 --border=rounded --border-label " セッション " \
        --prompt '󰍉  ' --pointer '▶ ' --ghost 'search sessions' \
        --header "$(count $lines) sessions · enter to switch" --header-first \
        --preview 'rex window ls -s {2}' --preview-window 'right,55%,border-left' \
        --preview-label ' tabs ')
    test -n "$pick"; or return 0
    set -l f (string split \t -- $pick)
    rex -C $client do session.select session_id=$f[2] >/dev/null
end
