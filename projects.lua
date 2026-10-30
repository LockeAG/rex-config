local home = os.getenv("HOME")
local shell = "com.superlogical.terminal.shell"
local roots = { home .. "/Development", home .. "/Documents", home .. "/Server" }
local extra = { home .. "/.dotfiles" }
local zoxide_limit = 40

local function lines(argv)
  local r = rex.exec(argv, { timeout = 5 })
  local out = {}
  if r and r.ok then
    for line in r.stdout:gmatch("[^\n]+") do out[#out + 1] = line end
  end
  return out
end

local dirs, seen = {}, {}
local function add(path)
  if path ~= home and not seen[path] then
    seen[path] = true
    dirs[#dirs + 1] = path
  end
end

for i, path in ipairs(lines({ "/opt/homebrew/bin/zoxide", "query", "-l" })) do
  if i > zoxide_limit then break end
  add(path)
end
for _, path in ipairs(extra) do add(path) end
for _, root in ipairs(roots) do
  for _, path in ipairs(lines({ "/usr/bin/find", root, "-mindepth", "1", "-maxdepth", "1",
    "-type", "d", "-not", "-name", ".*" })) do
    add(path)
  end
end

local function open(path, label)
  local list = rex.call("session.list")
  for _, s in ipairs(list and list.sessions or {}) do
    if s.label == label then
      rex.client.queue("session.select", { session_id = s.session_id })
      return
    end
  end
  local created, err = rex.call("session.create", {
    label = label,
    initial_windows = { { window_label = label, layout = { block = { flavor = shell, options = { cwd = path } } } } },
  })
  if err then error(err, 0) end
  rex.client.queue("session.select", { session_id = created.session_id })
end

local names = {}
for _, path in ipairs(dirs) do
  local label = path:match("([^/]+)$")
  local rel = path:sub(1, #home + 1) == home .. "/" and path:sub(#home + 2) or path
  local name = "session_" .. rel:lower():gsub("[^a-z0-9]+", "_")
  if label and not names[name] then
    names[name] = true
    rex.action{
      name = name,
      title = "Session: " .. label,
      description = path,
      category = "Sessions",
      keywords = path,
      run = function() open(path, label) end,
    }
  end
end
