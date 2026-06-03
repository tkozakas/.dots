local M = {}

function M.open_cmd()
	return vim.fn.has("mac") == 1 and "open" or "xdg-open"
end

function M.word_grep(glob_filter)
	local word = vim.fn.expand("<cword>")
	require("telescope").extensions.live_grep_args.live_grep_args({
		default_text = '"' .. word .. '"' .. (glob_filter ~= "" and " " .. glob_filter or ""),
	})
end

-- Cache git roots by directory path to avoid repeated synchronous process spawns
local git_root_cache = {}

function M.git_root_cached(dir)
	if git_root_cache[dir] then
		return git_root_cache[dir]
	end
	local root =
		vim.fn.systemlist("git -C " .. vim.fn.shellescape(dir) .. " rev-parse --show-toplevel 2>/dev/null")[1]
	if root and root ~= "" and vim.v.shell_error == 0 then
		git_root_cache[dir] = root
	else
		git_root_cache[dir] = dir
	end
	return git_root_cache[dir]
end

function M.git_root()
	return M.git_root_cached(vim.fn.getcwd())
end

function M.open_or_create_pr()
	local cwd
	if vim.bo.filetype == "oil" then
		cwd = require("oil").get_current_dir()
	else
		local bufname = vim.api.nvim_buf_get_name(0)
		-- Skip non-file buffers (gitsigns://, oil://, fugitive://, term://, etc.)
		if bufname == "" or bufname:match("^%w+://") then
			cwd = vim.fn.getcwd()
		else
			cwd = vim.fn.fnamemodify(bufname, ":p:h")
		end
	end
	if not cwd or cwd == "" or vim.fn.isdirectory(cwd) == 0 then
		cwd = vim.fn.getcwd()
	end

	local branch = vim.trim(vim.fn.system("git -C " .. vim.fn.shellescape(cwd) .. " rev-parse --abbrev-ref HEAD"))
	if branch == "master" or branch == "main" then
		vim.notify("On " .. branch .. ", switch branches first", vim.log.levels.WARN)
		return
	end

	vim.system({ "git", "push", "-u", "origin", "HEAD" }, { cwd = cwd }, function(push)
		if push.code ~= 0 then
			vim.schedule(function() vim.notify("Push failed", vim.log.levels.ERROR) end)
			return
		end
		vim.system({ "gh", "pr", "view", "--web" }, { cwd = cwd }, function(pr)
			if pr.code ~= 0 then
				vim.system({ "gh", "pr", "create", "--fill", "--web" }, { cwd = cwd })
			end
		end)
	end)
end

function M.open_in_gh()
	local file_path = vim.fn.expand("%:p")
	local file_dir = vim.fn.expand("%:p:h")

	local remote_cmd = vim.system({ "git", "remote", "get-url", "origin" }, { cwd = file_dir }):wait()
	if remote_cmd.code ~= 0 then
		vim.notify("Not a git repository or origin is not set", vim.log.levels.ERROR)
		return
	end

	local raw = vim.trim(remote_cmd.stdout)
	local base_url
	if raw:match("^https?://") then
		base_url = raw:gsub("%.git$", "")
	else
		local host, path = raw:match("^git@([^:]+):(.+)$")
		if not host then
			vim.notify("Unsupported remote format: " .. raw, vim.log.levels.ERROR)
			return
		end
		base_url = "https://" .. host .. "/" .. path:gsub("%.git$", "")
	end

	local rel_cmd = vim.system(
		{ "git", "ls-files", "--full-name", file_path },
		{ cwd = file_dir }
	):wait()
	local rel_path = vim.trim(rel_cmd.stdout)
	if rel_path == "" then
		vim.notify("File not tracked by git", vim.log.levels.WARN)
		return
	end

	local default_branch_cmd = vim.system(
		{ "git", "rev-parse", "--verify", "--quiet", "refs/heads/main" },
		{ cwd = file_dir }
	):wait()
	local branch = default_branch_cmd.code == 0 and "main" or "master"

	local line_no = vim.api.nvim_win_get_cursor(0)[1]
	local url = string.format("%s/blob/%s/%s#L%d", base_url, branch, rel_path, line_no)

	local open_cmd = M.open_cmd()
	vim.system({ open_cmd, url })
end
return M
