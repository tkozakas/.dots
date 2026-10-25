local M = {}

local LIMIT = 200

local function decode(s)
  return (s:gsub("%%(%x%x)", function(h)
    return string.char(tonumber(h, 16))
  end))
end

local function position(line, col, end_line)
  line = tonumber(line)
  if not line then
    return nil
  end
  local col_n = tonumber(col)
  return {
    pos = { line, col_n and math.max(col_n - 1, 0) or 0 },
    end_pos = tonumber(end_line) and { tonumber(end_line), 0 } or nil,
  }
end

local function github(query)
  local rest = query:match("^https?://[^/]*github[^/]*/[^/]+/[^/]+/blob/(.+)$")
  if not rest then
    return nil
  end
  local path = rest:match("^[^#?]+")
  local frag = rest:match("#(.*)$") or ""
  local l1, c1 = frag:match("^L(%d+)C?(%d*)")
  local l2 = frag:match("%-L(%d+)")
  local parts = vim.split(decode(path), "/", { plain = true })
  table.remove(parts, 1)
  return { segments = parts, loc = position(l1, c1, l2) }
end

local LOCATION_PATTERNS = {
  "^(.-)#L(%d+)C?(%d*)%-?L?(%d*)$",
  "^(.-):(%d+):(%d+)",
  "^(.-):(%d+)%-(%d+)$",
  "^(.-):(%d+)",
  "^(.-)%((%d+)%)$",
}

local function location(query)
  for i, p in ipairs(LOCATION_PATTERNS) do
    local path, a, b, c = query:match(p)
    if path and path:find("[%./]") and not path:find("%s") then
      if i == 1 then
        return path, position(a, b, c)
      elseif i == 3 then
        return path, position(a, nil, b)
      end
      return path, position(a, b)
    end
  end
  return query, nil
end

local function normalize(query)
  if query:find("/", 1, true) then
    return query:lower()
  end
  query = query:gsub("#.*$", ""):gsub("::", "/")
  local stem, ext = query:match("^(.*)%.(%l[%l%d]?[%l%d]?[%l%d]?)$")
  if stem then
    query = stem:gsub("%.", "/") .. "." .. ext
  else
    query = query:gsub("%.", "/")
  end
  return query:lower()
end

---@return {text:string, exact?:string[], loc?:{pos:number[], end_pos?:number[]}, grep:boolean}
function M.parse(query)
  query = vim.trim(query)
  local gh = github(query)
  if gh then
    return { text = normalize(gh.segments[#gh.segments] or ""), exact = gh.segments, loc = gh.loc, grep = false }
  end
  local path, loc = location(query)
  local exact = path:find("/", 1, true) and vim.split(path, "/", { plain = true }) or nil
  return { text = normalize(path), exact = exact, loc = loc, grep = loc == nil }
end

local function resolve(root, segments)
  for i = 1, #segments do
    local rel = table.concat(segments, "/", i)
    local stat = rel ~= "" and vim.uv.fs_stat(root .. "/" .. rel)
    if stat and stat.type == "file" then
      return rel
    end
  end
end

local listed = setmetatable({}, { __mode = "k" })

---@async
local function list_files(opts, ctx)
  local cached = listed[ctx.picker]
  if cached then
    return cached
  end
  local filter = setmetatable({ search = "" }, { __index = ctx.filter })
  local fctx = setmetatable({ filter = filter }, { __index = ctx })
  local files = {}
  local find = require("snacks.picker.source.files").files(opts, fctx)
  find(function(item)
    files[#files + 1] = item.file
  end)
  listed[ctx.picker] = files
  return files
end

local function item(cwd, file, loc)
  return {
    file = file,
    text = file,
    cwd = cwd,
    pos = loc and loc.pos,
    end_pos = loc and loc.end_pos,
  }
end

function M.files(opts, ctx)
  local search = vim.trim(ctx.filter.search)
  if search == "" then
    return {}
  end
  local q = M.parse(search)
  local cwd = ctx:cwd()
  ---@async
  return function(cb)
    if q.exact then
      local rel = resolve(cwd, q.exact)
      if rel then
        cb(item(cwd, rel, q.loc))
        return
      end
    end
    local matcher = require("snacks.picker.core.matcher").new({ filename_bonus = true })
    matcher:init(q.text)
    local scored = {}
    for i, file in ipairs(list_files(opts, ctx)) do
      local score = matcher:match({ file = file, text = file })
      if score > 0 then
        scored[#scored + 1] = { file = file, score = score }
      end
      if i % 5000 == 0 then
        require("snacks.picker.util.async").yield()
      end
    end
    table.sort(scored, function(a, b)
      if a.score ~= b.score then
        return a.score > b.score
      end
      return #a.file < #b.file
    end)
    for i = 1, math.min(#scored, LIMIT) do
      cb(item(cwd, scored[i].file, q.loc))
    end
  end
end

function M.grep(opts, ctx)
  local search = vim.trim(ctx.filter.search)
  if search == "" or not M.parse(search).grep then
    return {}
  end
  return require("snacks.picker.source.grep").grep(opts, ctx)
end

return M
