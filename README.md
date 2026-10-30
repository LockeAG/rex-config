# rex-config

My configuration for [Rex](https://www.superlogical.com/rex), Superlogical's terminal multiplexer. I moved to Rex from tmux, so the keys keep tmux habits: a `Ctrl+A` prefix, `h j k l` to move between panes, and a picker for tabs. Most things also have a direct `Cmd` shortcut.

It's tested on Rex Beta 0.1.0 (1541) on macOS, with fish as the shell.

This is my workflow, and it's what works for me. It isn't a recommended setup or a framework. Take what's useful and change the rest.

## Files

| File | What it does |
| --- | --- |
| `init.lua` | Loads the other four files. |
| `actions.lua` | Custom actions: tab switching, the tab picker, a scratch shell, zen mode, popups and a theme. |
| `keys.lua` | Direct shortcuts, mostly `Cmd`. |
| `prefix.lua` | tmux-style shortcuts after `Ctrl+A`. |
| `projects.lua` | One "Session: name" action per project folder, to open or create a session for it. |
| `fish/rex-windows.fish` | The fzf picker behind `Cmd+M`. |

## Install

You need Rex, fish, [fzf](https://github.com/junegunn/fzf), [jq](https://jqlang.org) and [zoxide](https://github.com/ajeetdsouza/zoxide).

```fish
git clone <this repo> ~/src/rex-config
mkdir -p ~/.config/rex
for f in ~/src/rex-config/*.lua
    ln -s $f ~/.config/rex/
end
ln -s ~/src/rex-config/fish/rex-windows.fish ~/.config/fish/functions/
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
| `Cmd+O` or `Cmd+S` | Switch session |
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
| `o` or `s` | Switch session |
| `b` | Previous session |
| `Ctrl+C` | New session |
| `R` | Rename session |
| `Q` | Close session |
| `v` | Find |
| `Ctrl+R` | Reload config |

## Actions

**Tab picker** (`Cmd+M`). An fzf list of the current session's tabs, numbered the way `Cmd+1` to `Cmd+9` reach them. Type to filter, Enter to jump. If nothing matches, Enter opens a new tab with what you typed as its name.

**Go to tab N** (`Cmd+1` to `Cmd+9`). Rex's own "go to tab" counted tabs in the session I had just left, so this action takes the Nth tab from the current session instead. See Known issues.

**Last tab** (`Cmd+Shift+B`). Jumps back to the previous tab in the session, like tmux's `last-window`. It only knows about switches made with this config's tab keys and picker.

**Scratch shell** (``Cmd+` ``). A floating shell that keeps running between uses. Press it again to hide it.

**Zen mode** (`Cmd+Z`). Floats the focused pane in a centred column. If the pane was alone in its tab, an empty backdrop pane holds the layout while it floats. Press it again to put the pane back.

**Project sessions.** In the command palette, "Session: name" opens the session for that folder, or creates it. The list comes from zoxide's 40 most used folders plus the first level of `~/Development`, `~/Documents` and `~/Server`. Edit `roots` and `extra` at the top of `projects.lua` to use your own.

## Make it yours

A few actions call my own scripts. They won't work on your machine until you swap in your own commands or delete them:

- `tools` in `actions.lua`: popups for notes search (`iggy-search`, `Ctrl+A n`), a kubectl cheatsheet (`kcheat`, `Ctrl+A Alt+K`), GitHub Actions runs (`gha`, `Ctrl+A g` and `G`) and a tmux cheatsheet (`Ctrl+A ?`).
- `sd` (`Cmd+G`) types `sd`, my directory search, into a fish prompt.
- `theme_tokyonight` reads the Tokyo Night theme from the Ghostty app.
- `Cmd+J` and `Cmd+Shift+W` send `Alt+J` and `Alt+W`, which my shell binds.

## Known issues

**Go to tab N works locally, not from a remote client.** The action asks the server's own CLI to run "Go to Session" for the client. It took that detour because the direct routes failed on the local app:

- `client.tab.goto` counts tabs in the session you just left;
- queuing `session.select` on the client didn't change the tab;
- `rex.session.focus_window` didn't either.

From a Rex app connected to a remote host, every version fails with `session "…" was not found on this server`. Last tab has the same limit. If you know the intended way to do this, please open an issue.

## Lessons from moving off tmux

I moved about fifty long-running terminal programs (AI coding agents, mostly) from tmux to Rex in one day. These are the things that cost me time.

- **A tab's command has no shell behind it.** When the program exits, the tab closes, and with `--keep-open` it freezes on the dead output. End the command with `; exec fish` and an exit drops you to a shell in the same folder.
- **Run the program in the foreground.** A tab started as `fish -c "status job-control full; <command>"` puts the program in the foreground, so Rex and your scripts see it as the tab's running process.
- **A dead tab can look alive.** If you ask a tab what runs in its foreground, a tab whose program has exited answers with an empty string, not an error. Check for the empty string.
- **The CLI looks blocks up in your own session.** Inside a Rex tab, `rex` uses `$REX_SESSION`, so `-b <block>` from another session reads "not found". Scripts that work across sessions should drop it first, for example `env -u REX_SESSION -u REX_BLOCK rex …`.
- **The server outlives the app.** Quitting Rex doesn't reload anything. Config changes need `rex config reload` or `Cmd+Shift+R`.
- **Appearance isn't in `~/.config/rex`.** Fonts, theme and window settings live in macOS defaults under `com.superlogical.rex`. To copy them to another Mac, export and import that domain while Rex is quit.
- **The app reaches a remote host, the CLI may not.** Rex's built-in Tailscale gives the app a route, but macOS itself isn't on the tailnet. Without the Tailscale app, `rex -S <host>` fails with "no such host".
- **Pastes submit at once in some programs.** Pasting into Claude Code in a Rex tab sends the message immediately. Don't use a paste to test what's in a prompt.
- **Stow folds the folder.** `stow rex` can turn `~/.config/rex` into a single link to the repo. Use `stow --no-folding rex` to get one link per file.
- **zoxide can hold `/`.** That path has no folder name to use as a label, which crashed `projects.lua` until it skipped the entry.

## Updates

This repo is a copy of the Rex part of my dotfiles, and I update it from there. Issues and suggestions are welcome.
