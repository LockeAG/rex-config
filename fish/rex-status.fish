function rex-status -d "Coloured status dot per Rex session and window, as JSON"
    # Programs report idle, working, done, blocked or error (OSC 7501). A window
    # or session shows its most urgent one, in Tokyo Night colours.
    rex do -e '
local rank = { idle = 1, working = 2, done = 3, blocked = 4, error = 4 }
local colour = { idle = "224;175;104", working = "255;158;100", done = "158;206;106",
  blocked = "247;118;142", error = "247;118;142" }
local best = {}
-- Rex keeps a done record until it is replaced; only the app knows what you
-- have seen. A done older than half an hour counts as idle.
local now = os.time()
local localoff = os.difftime(now, os.time(os.date("!*t", now)))
local function age(ts)
  local y, mo, d, h, mi, s, tz = (ts or ""):match("^(%d+)-(%d+)-(%d+)T(%d+):(%d+):(%d+)[%.%d]*(.*)$")
  if not y then return 0 end
  local off = 0
  local sign, oh, om = tz:match("^([+-])(%d+):(%d+)$")
  if sign then off = (sign == "-" and -1 or 1) * (tonumber(oh) * 3600 + tonumber(om) * 60) end
  local t = os.time{ year = tonumber(y), month = tonumber(mo), day = tonumber(d),
    hour = tonumber(h), min = tonumber(mi), sec = tonumber(s) }
  return now - (t + localoff - off)
end
local function note(id, state)
  if id and (rank[state] or 0) > (rank[best[id]] or 0) then best[id] = state end
end
local list = rex.call("session.list")
for _, s in ipairs(list and list.sessions or {}) do
  -- A connection reads only the sessions it has attached to.
  rex.call("session.attach", { session_id = s.session_id })
  local blocks = rex.call("session.list_blocks", { session_id = s.session_id })
  for _, b in ipairs(blocks and blocks.blocks or {}) do
    local r = rex.block.call("com.superlogical.terminal", "program_status",
      { session_id = s.session_id, block_id = b.block_id })
    for _, rec in ipairs(r and r.records or {}) do
      local state = rec.state
      if state == "done" and age(rec.updated_at) > 1800 then state = "idle" end
      note(s.session_id, state)
      note(b.window_id, state)
    end
  end
end
local dots = { _ = "" }
for id, state in pairs(best) do dots[id] = "\27[38;2;" .. colour[state] .. "m●\27[0m" end
print(rex.json.encode(dots))'
end
