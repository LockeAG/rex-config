function rex-windows -d "fzf picker over the current Rex session's windows (Rex cmd+m)"
    set -l current $argv[2]
    # A remote app's key passes its id on its own server; the popup's owner is
    # the same app as this server knows it.
    set -l client (rex block ls -s $current --json | jq -r --arg b "$REX_BLOCK" '.blocks[] | select(.block_id == $b) | .owner // empty')
    test -n "$client"; or set client $argv[1]
    # Numbered as cmd+1..9 reaches them.
    set -l lines (rex window ls -s $current --json | jq -r '. as $s | .windows | to_entries[] |
        "\(.key + 1)  \(.value.label)\t\($s.session_id)\t\(.value.window_id)"')
    set -l name (rex ls --json | jq -r --arg c $current '.sessions[] | select(.session_id == $c) | .label')
    set -l pick (printf '%s\n' $lines | fzf --ansi --cycle --highlight-line --reverse --no-sort \
        --delimiter \t --with-nth 1 --border=rounded --border-label " 窓 $name " \
        --prompt '󰍉  ' --pointer '▶ ' --ghost 'search or name a new window' \
        --bind 'enter:accept-or-print-query')
    test -n "$pick"; or return 0
    if not string match -q '*'\t'*' -- $pick
        rex window new -s $current -c $PWD (string trim -- $pick) >/dev/null
        return
    end
    set -l f (string split \t -- $pick)
    set -l err (rex -C $client do session.select session_id=$f[2] window_id=$f[3] 2>&1 >/dev/null)
    or begin
        printf 'rex-windows: %s\n' $err
        read -P 'press Enter ' -l _
        return 1
    end
end
