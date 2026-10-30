local ghostty_themes = "/Applications/Ghostty.app/Contents/Resources/ghostty/themes/"
local terminal = "com.superlogical.terminal"
local shell = "com.superlogical.terminal.shell"

rex.action{
  name = "theme_tokyonight",
  title = "Theme: Tokyo Night",
  category = "Appearance",
  keywords = "tokyonight ghostty",
  run = function()
    rex.client.queue("client.theme.import", { path = ghostty_themes .. "TokyoNight Night" })
  end,
}

local function cwd_of(ctx, api)
  if not ctx.block_id then return nil end
  local r = (api or rex).block.call(terminal, "pwd", { session_id = ctx.session_id, block_id = ctx.block_id })
  local url = r and (r.pwd or r.url)
  return url and (url:gsub("^file://[^/]*", "")) or nil
end

-- Pressing a popup's key again closes it rather than stacking a second one.
local function popup(ctx, label, command, bounds, api)
  api = api or rex
  local list = api.call("session.list_blocks", { session_id = ctx.session_id })
  for _, b in ipairs(list and list.blocks or {}) do
    if b.label == label and b.placement ~= "detached" then
      return api.call("block.close", { session_id = ctx.session_id, block_id = b.block_id })
    end
  end
  local _, err = api.session.new_layer{
    session_id = ctx.session_id,
    bounds = bounds or { 0.05, 0.05, 0.9, 0.9 },
    focus = true,
    layout = rex.layout.block{
      flavor = shell,
      label = label,
      options = { command = command, cwd = cwd_of(ctx, api) },
    },
  }
  if err then error(err, 0) end
end

local tools = {
  { name = "notes", title = "Notes", command = { "fish", "-c", "iggy-search" } },
  { name = "kcheat", title = "Kubectl Cheatsheet", command = { "fish", "-c", "kcheat" } },
  { name = "help", title = "Tmux Cheatsheet", command = { os.getenv("HOME") .. "/.tmux/scripts/help.sh" } },
  { name = "gh_runs", title = "GitHub Runs", command = { "fish", "-c", "gha fzf runs" },
    bounds = { 0.2, 0.25, 0.6, 0.45 } },
  { name = "gh_run_detail", title = "GitHub Run Detail", command = { "fish", "-c", "gha fzf runs --action detail" },
    bounds = { 0.2, 0.25, 0.6, 0.45 } },
}

for _, t in ipairs(tools) do
  rex.action{
    name = t.name,
    title = t.title,
    category = "Popups",
    run = function(ctx) popup(ctx, t.name, t.command, t.bounds) end,
  }
end

local function find_block(label)
  local blocks = rex.session.list_blocks{}
  for _, b in ipairs(blocks and blocks.blocks or {}) do
    if b.label == label then return b end
  end
end

local function floating_in(window, block_id)
  for _, layer in ipairs(window.layers or {}) do
    if layer.kind ~= "tiled" then
      for _, b in ipairs(layer.blocks or {}) do
        if b.block_id == block_id then return true end
      end
    end
  end
  return false
end

rex.action{
  name = "scratch",
  title = "Scratch Shell",
  category = "Popups",
  run = function(ctx)
    local view = rex.session.view{}
    local window
    for _, w in ipairs(view.windows or {}) do
      if w.window_id == view.active_window_id then window = w end
    end
    local scratch = find_block("scratch")
    if not scratch then
      return popup(ctx, "scratch", nil)
    end
    if window and floating_in(window, scratch.block_id) then
      rex.session.detach_block{ block_id = scratch.block_id }
      return
    end
    if scratch.placement ~= "detached" then
      rex.session.detach_block{ block_id = scratch.block_id }
    end
    local anchor = ctx.block_id
    if not anchor or anchor == scratch.block_id then
      anchor = window and window.focused_block_id
    end
    local _, err = rex.session.move_block{
      block_id = scratch.block_id,
      anchor_block_id = anchor,
      direction = "vertical",
    }
    if err then error(err, 0) end
    rex.session.float_block{ block_id = scratch.block_id, bounds = { 0.05, 0.05, 0.9, 0.9 } }
    rex.session.focus_block{ block_id = scratch.block_id }
  end,
}

local backdrop = "zen-backdrop"

local function locate(view, block_id)
  for _, w in ipairs(view.windows or {}) do
    local tiled, backdrops, floating, found = {}, {}, false, false
    for _, layer in ipairs(w.layers or {}) do
      for _, b in ipairs(layer.blocks or {}) do
        if layer.kind == "tiled" then
          if b.label == backdrop then backdrops[#backdrops + 1] = b.block_id end
          tiled[#tiled + 1] = b.block_id
        end
        if b.block_id == block_id then
          found, floating = true, layer.kind ~= "tiled"
        end
      end
    end
    if found then return tiled, backdrops, floating end
  end
end

local function check(_, err)
  if err then error(err, 0) end
end

rex.action{
  name = "zen",
  title = "Zen Pane",
  category = "Panes",
  run = function(ctx)
    local tiled, backdrops, floating = locate(rex.session.view{}, ctx.block_id)
    if not tiled then return end
    if floating then
      check(rex.session.move_block{
        block_id = ctx.block_id,
        anchor_block_id = tiled[#tiled],
        direction = "horizontal",
      })
      for _, id in ipairs(backdrops) do rex.call("block.close", { session_id = ctx.session_id, block_id = id }) end
      rex.session.focus_block{ block_id = ctx.block_id }
      return
    end
    if #tiled == 1 then
      check(rex.session.new_split{
        anchor_id = ctx.block_id,
        direction = "horizontal",
        side = "after",
        layout = rex.layout.block{
          flavor = shell,
          label = backdrop,
          options = { command = { "/bin/sh", "-c", "trap exit TERM; while :; do sleep 3600; done" } },
        },
      })
    end
    check(rex.session.float_block{ block_id = ctx.block_id, bounds = { 0.27, 0.02, 0.45, 0.96 } })
    rex.session.focus_block{ block_id = ctx.block_id }
  end,
}

local tabs = {}

local function note(at, session_id)
  local view = at.api.session.view{ session_id = session_id }
  local t = tabs[session_id] or {}
  if view.active_window_id ~= t.cur then t.prev, t.cur = t.cur, view.active_window_id end
  tabs[session_id] = t
  return t, view
end

-- A client attached to a remote host runs its keys on its own server, which
-- doesn't have the host's sessions. The work then goes to the server that has
-- the session, addressed to the app's own connection there.
local function has(api, session_id)
  local list = api.call("session.list")
  for _, s in ipairs(list and list.sessions or {}) do
    if s.session_id == session_id then return true end
  end
  return false
end

local function app_on(api)
  local me = api.call("server.whoami")
  local node = me and me.principal and me.principal.node
  local list = api.call("client.list")
  for _, c in ipairs(list and list.clients or {}) do
    if c.info and c.info.kind == "app" and c.principal and c.principal.node == node then return c.client_id end
  end
end

local function where(ctx)
  if has(rex, ctx.session_id) then return { api = rex, client = ctx.client_id } end
  for _, label in ipairs(rex.servers()) do
    local api = rex.server(label)
    if has(api, ctx.session_id) then
      local client = app_on(api)
      if not client then error("No Rex app of this machine is attached to " .. label, 0) end
      -- Session calls on a remote server need the stream attached first. A
      -- repeat attach may fail; any real failure shows in the next call.
      api.call("session.attach", { session_id = ctx.session_id })
      return { api = api, client = client, remote = true }
    end
  end
  error("No server has this session", 0)
end

-- A queued session.select resolves on the client's own server, so a local jump
-- goes through this server's CLI instead.
local function jump(ctx, at, window_id)
  if at.remote then
    return check(at.api.call("client.perform", { client_id = at.client, action = "session.select",
      args = { session_id = ctx.session_id, window_id = window_id } }))
  end
  rex.exec({ os.getenv("HOME") .. "/.local/bin/rex", "-C", ctx.client_id, "do", "session.select",
    "session_id=" .. ctx.session_id, "window_id=" .. window_id }, { timeout = 5 })
end

rex.action{
  name = "tab",
  title = "Switch Tab",
  category = "Tabs",
  run = function(ctx, args)
    if not (args and args.action) then return end
    local at = where(ctx)
    local _, view = note(at, ctx.session_id)
    if args.index then
      -- client.tab.goto counts in another session after a switch, so the
      -- window is picked from this session's own list.
      local w = (view.windows or {})[args.index]
      if w then jump(ctx, at, w.window_id) end
      return
    end
    rex.client.queue(args.action)
  end,
}

rex.action{
  name = "last_tab",
  title = "Last Tab",
  category = "Tabs",
  run = function(ctx)
    local at = where(ctx)
    local t, view = note(at, ctx.session_id)
    for _, w in ipairs(view.windows or {}) do
      if w.window_id == t.prev then
        return jump(ctx, at, t.prev)
      end
    end
  end,
}

rex.action{
  name = "windows",
  title = "Windows",
  category = "Popups",
  run = function(ctx)
    local at = where(ctx)
    note(at, ctx.session_id)
    popup(ctx, "windows", { "fish", "-c", "rex-windows " .. at.client .. " " .. ctx.session_id },
      { 0.25, 0.2, 0.5, 0.5 }, at.api)
  end,
}

rex.action{
  name = "sessions",
  title = "Sessions",
  category = "Popups",
  run = function(ctx)
    local at = where(ctx)
    popup(ctx, "sessions", { "fish", "-c", "rex-sessions " .. at.client .. " " .. ctx.session_id },
      { 0.1, 0.1, 0.8, 0.8 }, at.api)
  end,
}

rex.action{
  name = "sd",
  title = "Search Directories",
  run = function(ctx)
    local p = rex.block.call(terminal, "process", { block_id = ctx.block_id })
    if not (p and p.foreground and p.foreground.name == "fish") then return end
    rex.block.call(terminal, "write", { block_id = ctx.block_id, data = "sd\r" })
  end,
}
