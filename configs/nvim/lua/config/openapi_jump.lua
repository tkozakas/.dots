local M = {}

local METHODS = { get = true, post = true, put = true, patch = true, delete = true, head = true, options = true }

local routes = {}
local loading = {}

local function rails_root(file)
  local rails = vim.fs.find("bin/rails", { path = vim.fs.dirname(file), upward = true, type = "file" })[1]
  return rails and vim.fs.dirname(vim.fs.dirname(rails))
end

local function normalize(path)
  return (path:gsub("%(%.:format%)$", ""):gsub("{[^}]+}", ":"):gsub(":[%w_]+", ":"):gsub("/$", ""))
end

local function parse_routes(lines)
  local parsed = {}
  for _, line in ipairs(lines) do
    local verbs, path, controller, action = line:match("(%u[%u|]*)%s+(/%S*)%s+([%w_/]+)#([%w_]+)")
    if verbs then
      local route = { path = normalize(path), verbs = {}, controller = controller, action = action }
      for verb in verbs:gmatch("%u+") do
        route.verbs[verb:lower()] = true
      end
      parsed[#parsed + 1] = route
    end
  end
  return parsed
end

local function with_routes(root, cb)
  if routes[root] then
    return cb(routes[root])
  end
  if loading[root] then
    table.insert(loading[root], cb)
    return
  end
  loading[root] = { cb }
  vim.notify("Loading Rails routes…")
  vim.system({ "bin/rails", "routes" }, { cwd = root, text = true }, function(res)
    vim.schedule(function()
      local waiting = loading[root]
      loading[root] = nil
      if res.code ~= 0 then
        vim.notify("bin/rails routes failed:\n" .. (res.stderr or ""), vim.log.levels.ERROR)
        return
      end
      routes[root] = parse_routes(vim.split(res.stdout, "\n", { plain = true }))
      for _, fn in ipairs(waiting) do
        fn(routes[root])
      end
    end)
  end)
end

local function operation_at_cursor()
  local row = vim.api.nvim_win_get_cursor(0)[1]
  local lines = vim.api.nvim_buf_get_lines(0, 0, row, false)
  local method, method_indent
  for i = row, 1, -1 do
    local indent, key = lines[i]:match("^(%s*)['\"]?([%w_/{}%.%-]+)['\"]?:%s*$")
    if key then
      if not method and METHODS[key] then
        method, method_indent = key, #indent
      elseif key:sub(1, 1) == "/" and (not method_indent or #indent < method_indent) then
        return key, method
      end
    end
  end
end

local function find_controller(root, controller)
  local rel = "app/controllers/" .. controller .. "_controller.rb"
  local matches = vim.fn.glob(root .. "/" .. rel, false, true)
  vim.list_extend(matches, vim.fn.glob(root .. "/packages/*/" .. rel, false, true))
  return matches[1]
end

local function open_action(file, action)
  vim.cmd.edit(vim.fn.fnameescape(file))
  local lnum = vim.fn.search("^\\s*def " .. action .. "\\>", "w")
  if lnum > 0 then
    vim.cmd("normal! zz")
  end
end

function M.jump(fallback)
  local file = vim.api.nvim_buf_get_name(0)
  local path, method = operation_at_cursor()
  local root = path and rails_root(file)
  if not root then
    return fallback()
  end
  local wanted = normalize(path)
  with_routes(root, function(list)
    local hits = {}
    for _, route in ipairs(list) do
      if route.path == wanted and (not method or route.verbs[method]) then
        hits[#hits + 1] = route
      end
    end
    if #hits == 0 then
      vim.notify(("No route for %s %s"):format(method and method:upper() or "*", path), vim.log.levels.WARN)
      return
    end
    local function go(route)
      local controller = find_controller(root, route.controller)
      if not controller then
        vim.notify("Controller not found: " .. route.controller, vim.log.levels.WARN)
        return
      end
      open_action(controller, route.action)
    end
    if #hits == 1 then
      return go(hits[1])
    end
    vim.ui.select(hits, {
      prompt = "Route",
      format_item = function(route)
        return ("%s %s#%s"):format(table.concat(vim.tbl_keys(route.verbs), "|"):upper(), route.controller, route.action)
      end,
    }, function(route)
      if route then
        go(route)
      end
    end)
  end)
end

function M.is_spec(buf)
  local name = vim.api.nvim_buf_get_name(buf)
  if not name:match("%.ya?ml$") then
    return false
  end
  for _, line in ipairs(vim.api.nvim_buf_get_lines(buf, 0, 5, false)) do
    if line:match("^openapi:") or line:match("^swagger:") then
      return true
    end
  end
  return false
end

function M.reload()
  routes = {}
end

return M
