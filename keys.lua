rex.bind("cmd+d", "pane.split", { direction = "right" })
rex.bind("cmd+shift+d", "pane.split", { direction = "down" })
rex.bind("cmd+shift+x", "pane.close")
rex.bind("cmd+shift+z", "pane.zoom")
rex.bind("cmd+z", "zen")
rex.bind("cmd+[Backquote]", "scratch")
rex.bind("cmd+alt+shift+o", "notes")
rex.bind("cmd+g", "sd")

for _, dir in ipairs({ "left", "right", "up", "down" }) do
  rex.bind("cmd+" .. dir, "pane.focus", { direction = dir })
  rex.bind("cmd+shift+" .. dir, "pane.resize", { direction = dir, amount = 5 })
end

rex.bind("cmd+t", "client.tab.new")
rex.bind("cmd+[BracketLeft]", "tab", { action = "client.tab.previous" })
rex.bind("cmd+[BracketRight]", "tab", { action = "client.tab.next" })
rex.bind("cmd+shift+b", "last_tab")
rex.bind("ctrl+alt+j", "tab", { action = "client.tab.next" })
rex.bind("ctrl+alt+k", "tab", { action = "client.tab.previous" })
rex.bind("ctrl+alt+shift+j", "client.tab.move.forward")
rex.bind("ctrl+alt+shift+k", "client.tab.move.backward")
for i = 1, 9 do
  rex.bind("cmd+" .. i, "tab", { action = "client.tab.goto", index = i })
end

rex.bind("cmd+o", "session.switch")
rex.bind("cmd+s", "session.switch")
rex.bind("cmd+n", "session.new")
rex.bind("cmd+shift+n", "session.new")
rex.bind("cmd+b", "session.previous")

rex.bind("cmd+m", "windows")
rex.bind("cmd+shift+a", "client.sidebar.activity.toggle")
rex.bind("cmd+shift+o", "client.sidebar.activity.toggle")
rex.bind("cmd+shift+s", "client.sidebar.toggle")
rex.bind("cmd+shift+c", "client.find.open")
rex.bind("cmd+alt+up", "client.prompt.previous")
rex.bind("cmd+alt+down", "client.prompt.next")
rex.bind("cmd+shift+r", "client.config.reload")

rex.bind("cmd+k", "pane.send_key", { key = "ctrl+l" })
rex.bind("cmd+j", "pane.send_key", { key = "alt+j" })
rex.bind("cmd+shift+w", "pane.send_key", { key = "alt+w" })
