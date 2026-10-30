# rex-config

A configuration for [Rex](https://www.superlogical.com/rex), Superlogical's terminal multiplexer. It grew out of a move from tmux, so the keys keep tmux habits: a `Ctrl+A` prefix, `h j k l` to move between panes, and a picker for tabs. Most things also have a direct `Cmd` shortcut.

It's tested on Rex Beta 0.1.0 (1541) on macOS, with fish as the shell.

> **Disclaimer:** this is my workflow, and it's what works for me. It's shared in case parts of it help with yours. Take what's useful and change the rest.

## Files

| File | What it does |
| --- | --- |
| `init.lua` | Loads the other four files. |
| `actions.lua` | Custom actions: tab switching, the tab picker, a scratch shell, zen mode, popups and a theme. |
| `keys.lua` | Direct shortcuts, mostly `Cmd`. |
| `prefix.lua` | tmux-style shortcuts after `Ctrl+A`. |
| `projects.lua` | One "Session: name" action per project folder, to open or create a session for it. |
| `fish/rex-windows.fish` | The fzf picker behind `Cmd+M`. |
| `fish/rex-sessions.fish` | The fzf picker behind `Cmd+O`, with a preview of each session's tabs. |
| `fish/rex-status.fish` | The status dots both pickers show. |

## Install

You need Rex, fish, [fzf](https://github.com/junegunn/fzf), [jq](https://jqlang.org) and [zoxide](https://github.com/ajeetdsouza/zoxide).

```fish
git clone <this repo> ~/src/rex-config
mkdir -p ~/.config/rex
for f in ~/src/rex-config/*.lua
    ln -s $f ~/.config/rex/
end
ln -s ~/src/rex-config/fish/rex-windows.fish ~/.config/fish/functions/
ln -s ~/src/rex-config/fish/rex-sessions.fish ~/.config/fish/functions/
ln -s ~/src/rex-config/fish/rex-status.fish ~/.config/fish/functions/
rex config reload
```

After that, `Cmd+Shift+R` reloads the config.

## Keys

### Direct

| Key | Does |
| --- | --- |
| `Cmd+1` … `Cmd+9` | Go to tab N in the current session |
| `Cmd+[` / `Cmd+]` | Previous / next tab |
| `Cmd+Shift+B` | Last tab |
| `Cmd+M` | Tab picker |
| `Cmd+T` | New tab |
| `Cmd+D` / `Cmd+Shift+D` | Split right / down |
| `Cmd+Shift+X` | Close pane |
| `Cmd+Shift+Z` | Zoom pane |
| `Cmd+Z` | Zen mode |
| ``Cmd+` `` | Scratch shell |
| `Cmd+arrows` / `Cmd+Shift+arrows` | Focus / resize panes |
| `Cmd+O` | Session picker |
| `Cmd+S` | Rex's built-in session switcher, with the sessions that just finished on top |
| `Cmd+B` | Previous session |
| `Cmd+N` | New session |
| `Cmd+Shift+S` | Sidebar |
| `Cmd+Shift+A` | Activity sidebar |
| `Cmd+Shift+C` | Find |
| `Cmd+Alt+Up` / `Cmd+Alt+Down` | Previous / next prompt |
| `Cmd+Shift+R` | Reload config |
| `Cmd+K` | Clear the screen (sends `Ctrl+L`) |

### After the `Ctrl+A` prefix

Press `Ctrl+A`, let go, then the key. `Ctrl+A` twice sends a real `Ctrl+A`.

| Key | Does |
| --- | --- |
| `h j k l` | Focus pane left, down, up, right |
| `H J K L` | Resize pane |
| `[` / `]` | Previous / next pane |
| `\|` / `_` | Split right / down |
| `x` | Close pane |
| `+` | Zoom pane |
| `Z` | Zen mode |
| `` ` `` | Scratch shell |
| `c` | New tab |
| `X` | Close tab |
| `r` | Rename tab |
| `m` | Tab picker |
| `Ctrl+0` | Last tab |
| `Shift+Left` / `Shift+Right` | Move tab |
| `o` | Session picker |
| `s` | Rex's built-in session switcher |
| `b` | Previous session |
| `Ctrl+C` | New session |
| `R` | Rename session |
| `Q` | Close session |
| `v` | Find |
| `Ctrl+R` | Reload config |

## Actions

**Tab picker** (`Cmd+M`). An fzf list of the current session's tabs, numbered the way `Cmd+1` to `Cmd+9` reach them. Type to filter, Enter to jump. If nothing matches, Enter opens a new tab with what you typed as its name.

**Status dots.** Both pickers put a dot before each tab and session, from the status programs report to Rex ([OSC 7501](https://www.superlogical.com/rex/docs)): green for done, orange for working, yellow for idle, red for blocked or error, in Tokyo Night colours. A session shows its most urgent tab. Rex keeps a "done" until the program replaces it, and only the app knows what you've already seen, so a done older than half an hour shows as idle. Pressing a picker's key again closes it.

**Session picker** (`Cmd+O`). A large fzf popup of every session, with the current one marked. The right side previews the highlighted session's tabs, with their dots. Type to filter, Enter to switch. Sessions you used recently come first and the current one goes last, so `Cmd+O` then Enter goes back to the previous session. It only knows about sessions you opened it in or picked from it; the list lives in `~/.local/state/rex-recent-sessions`.

**Rex's session switcher** (`Cmd+S`). I keep the built-in one too. It puts the sessions whose programs just finished at the top, so when I run many long jobs it's the fastest way to the one that needs me. `Cmd+O` is for finding a session by name and seeing its tabs first.

**Go to tab N** (`Cmd+1` to `Cmd+9`). In my setup, the built-in "go to tab" counted tabs in the previously viewed session, so this action takes the Nth tab from the current session instead. See Known issues.

**Last tab** (`Cmd+Shift+B`). Jumps back to the previous tab in the session, like tmux's `last-window`. It only knows about switches made with this config's tab keys and picker.

**Scratch shell** (``Cmd+` ``). A floating shell that keeps running between uses. Press it again to hide it.

**Zen mode** (`Cmd+Z`). Floats the focused pane in a centred column. If the pane was alone in its tab, an empty backdrop pane holds the layout while it floats. Press it again to put the pane back.

**Project sessions.** In the command palette, "Session: name" opens the session for that folder, or creates it. The list comes from zoxide's 40 most used folders plus the first level of `~/Development`, `~/Documents` and `~/Server`. Edit `roots` and `extra` at the top of `projects.lua` to use your own.

## Make it yours

A few actions call personal scripts. Replace them with your own commands, or remove them:

- `tools` in `actions.lua`: popups for notes search (`iggy-search`, `Ctrl+A n`), a kubectl cheatsheet (`kcheat`, `Ctrl+A Alt+K`), GitHub Actions runs (`gha`, `Ctrl+A g` and `G`) and a tmux cheatsheet (`Ctrl+A ?`).
- `sd` (`Cmd+G`) types `sd`, a directory search function, into a fish prompt.
- `theme_tokyonight` reads the Tokyo Night theme from the Ghostty app.
- `Cmd+J` and `Cmd+Shift+W` send `Alt+J` and `Alt+W` for shell bindings.

## Known issues

**A remote host knows your app by another ID.** When the app is connected to another Mac, the pickers open on that host and switch your app from there. Each Rex server gives the app its own client ID, so the ID your key passes in means nothing to the host. The pickers ask the host which client owns the popup they run in and use that ID instead. If a switch still fails, the popup keeps the error on screen until you press Enter.

**Go to tab N takes a detour.** On local sessions, the action asks the server's own CLI to run "Go to Session" for the client. It takes that route because, in my setup, the more direct options didn't switch tabs on the local app:

- `client.tab.goto` counted tabs in the previously viewed session;
- queuing `session.select` on the client didn't change the tab;
- `rex.session.focus_window` didn't either.

Rex is in beta, so this may change, and there may be a better way I've missed. If you know one, an issue would be very welcome.

## Lessons from moving off tmux

I moved about fifty long-running terminal programs, mostly AI coding agents, from tmux to Rex. These notes might save someone else some time.

- **A tab's command has no shell behind it.** When the program exits, the tab closes, and with `--keep-open` it freezes on the dead output. End the command with `; exec fish` and an exit drops you to a shell in the same folder.
- **Run the program in the foreground.** A tab started as `fish -c "status job-control full; <command>"` puts the program in the foreground, so Rex and your scripts see it as the tab's running process.
- **A dead tab can look alive.** If you ask a tab what runs in its foreground, a tab whose program has exited answers with an empty string, not an error. Check for the empty string.
- **The CLI looks blocks up in your own session.** Inside a Rex tab, `rex` uses `$REX_SESSION`, so `-b <block>` from another session reads "not found". Scripts that work across sessions should drop it first, for example `env -u REX_SESSION -u REX_BLOCK rex …`.
- **The server outlives the app.** Quitting Rex doesn't reload anything. Config changes need `rex config reload` or `Cmd+Shift+R`.
- **Appearance isn't in `~/.config/rex`.** Fonts, theme and window settings live in macOS defaults under `com.superlogical.rex`. To copy them to another Mac, export and import that domain while Rex is quit.
- **The app reaches a remote host, the CLI may not.** Rex's built-in Tailscale gives the app a route, but macOS itself isn't on the tailnet. Without the Tailscale app, `rex -S <host>` fails with "no such host".
- **Pastes submit at once in some programs.** Pasting into Claude Code in a Rex tab sends the message immediately. Don't use a paste to test what's in a prompt.
- **Stow folds the folder.** `stow rex` can turn `~/.config/rex` into a single link to the repo. Use `stow --no-folding rex` to get one link per file.
- **A client ID is only good on one server.** The same app has a different ID on every Rex server it connects to. A script that runs on a remote host and names your app by its local ID gets "client target not found".
- **zoxide can hold `/`.** That path has no folder name to use as a label, which crashed `projects.lua` until it skipped the entry.

## Updates

This repo is a copy of the Rex part of my dotfiles, and I update it from there. Issues and suggestions are welcome. Thanks to Superlogical for Rex.
