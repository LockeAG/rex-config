function rex-sessions -d "fzf picker over Rex sessions, previewing their tabs (Rex cmd+o)"
    set -l current $argv[2]
    # A remote app's key passes its id on its own server; the popup's owner is
    # the same app as this server knows it.
    set -l client (rex block ls -s $current --json | jq -r --arg b "$REX_BLOCK" '.blocks[] | select(.block_id == $b) | .owner // empty')
    test -n "$client"; or set client $argv[1]
    # Most recent first, the current session last, so Enter goes back.
    set -l file ~/.local/state/rex-recent-sessions
    set -l recent $current (string match -v -- $current (command cat $file 2>/dev/null))
    printf '%s\n' $recent[1..50] >$file
    set -l lines (rex ls --json | jq -r --arg c $current --argjson r (printf '%s\n' $recent | jq -Rsc 'split("\n")') '
        .sessions | to_entries | sort_by(.value.session_id as $id |
            (if $id == $c then 1e9 else ($r | index($id)) // 1e6 end), .key) | .[].value |
        "\(if .session_id == $c then "● " else "  " end)\(.label)\t\(.session_id)"')
    set -l pick (printf '%s\n' $lines | fzf --ansi --cycle --highlight-line --reverse --no-sort \
        --delimiter \t --with-nth 1 --border=rounded --border-label " セッション " \
        --prompt '󰍉  ' --pointer '▶ ' --ghost 'search sessions' \
        --header "$(count $lines) sessions · enter to switch" --header-first \
        --preview 'rex window ls -s {2}' --preview-window 'right,55%,border-left' \
        --preview-label ' tabs ')
    test -n "$pick"; or return 0
    set -l f (string split \t -- $pick)
    set -l err (rex -C $client do session.select session_id=$f[2] 2>&1 >/dev/null)
    or begin
        printf 'rex-sessions: %s\n' $err
        read -P 'press Enter ' -l _
        return 1
    end
    printf '%s\n' $f[2] $recent[1..49] >$file
end
