local function prefix(key, action, args)
  rex.bind("ctrl+a>" .. key, action, args)
end

prefix("ctrl+a", "pane.send_key", { key = "ctrl+a" })

prefix("shift+\\", "pane.split", { direction = "right" })
prefix("shift+-", "pane.split", { direction = "down" })
prefix("x", "pane.close")
prefix("shift+=", "pane.zoom")
prefix("shift+z", "zen")
prefix("[Backquote]", "scratch")
prefix("n", "notes")
prefix("shift+/", "help")
prefix("alt+k", "kcheat")
prefix("g", "gh_run_detail")
prefix("shift+g", "gh_runs")
prefix("[BracketLeft]", "pane.focus_previous")
prefix("[BracketRight]", "pane.focus_next")

for key, dir in pairs({ h = "left", j = "down", k = "up", l = "right" }) do
  prefix(key, "pane.focus", { direction = dir })
  prefix("shift+" .. key, "pane.resize", { direction = dir, amount = 5 })
end

prefix("c", "client.tab.new")
prefix("shift+x", "client.tab.close")
prefix("r", "client.tab.rename")
prefix("ctrl+[BracketLeft]", "tab", { action = "client.tab.previous" })
prefix("ctrl+[BracketRight]", "tab", { action = "client.tab.next" })
prefix("ctrl+0", "last_tab")
prefix("shift+left", "client.tab.move.backward")
prefix("shift+right", "client.tab.move.forward")

prefix("o", "sessions")
prefix("s", "session.switch")
prefix("b", "session.previous")
prefix("ctrl+c", "session.new")
prefix("shift+r", "session.rename")
prefix("shift+q", "session.close")

prefix("m", "windows")
prefix("shift+a", "client.sidebar.activity.toggle")
prefix("ctrl+s", "client.sidebar.toggle")
prefix("v", "client.find.open")
prefix("ctrl+r", "client.config.reload")
prefix("ctrl+l", "pane.send_key", { key = "ctrl+l" })
