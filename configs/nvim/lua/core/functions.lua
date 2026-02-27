local M = {}

function M.open_or_create_pr()
	local cwd = vim.bo.filetype == "oil" and require("oil").get_current_dir() or vim.fn.expand("%:p:h")
	if not cwd or cwd == "" then return end

	vim.system({ "git", "rev-parse", "--abbrev-ref", "HEAD" }, { cwd = cwd }, function(out)
		local branch = vim.trim(out.stdout)
		if branch == "master" or branch == "main" then
			vim.schedule(function() vim.notify("On " .. branch .. ", switch branches first", vim.log.levels.WARN) end)
			return
		end

		vim.system({ "git", "push", "-u", "origin", "HEAD" }, { cwd = cwd }, function()
			vim.system({ "gh", "pr", "view", "--web" }, { cwd = cwd }, function(pr)
				if pr.code ~= 0 then
					vim.system({ "gh", "pr", "create", "--fill", "--web" }, { cwd = cwd })
				end
			end)
		end)
	end)
end

function M.lazygit()
	local current_dir
	if vim.bo.filetype == "oil" then
		current_dir = require("oil").get_current_dir()
	else
		current_dir = vim.fn.expand("%:p:h")
	end
	if current_dir == nil or current_dir == "" then
		vim.notify("Could not determine directory.", vim.log.levels.ERROR)
		return
	end

	vim.fn.system("tmux new-window 'cd " .. vim.fn.shellescape(current_dir) .. " && lazygit'")
end

function M.copy_to_clipboard()
	vim.cmd("let @+ = expand('%')")
end

function M.Tmux_split(command_to_run)
	local current_pane = tonumber(vim.fn.system("tmux display-message -p '#P'"))
	local left_pane = tonumber(
		vim.fn
			.system("tmux list-panes -F '#{pane_index} #{pane_left}' | grep -v " .. current_pane .. " | awk '{print $1}'")
			:match("%S+")
	)

	if left_pane == nil then
		local current_file_dir = vim.fn.getcwd()
		vim.fn.system("tmux split-window -h -c " .. current_file_dir)

		left_pane = tonumber(
			vim.fn
				.system("tmux list-panes -F '#{pane_index} #{pane_left}' | grep -v " .. current_pane .. " | awk '{print $1}'")
				:match("%S+")
		)
	end

	vim.fn.system("tmux send-keys -t " .. left_pane .. " '" .. command_to_run .. "' C-m")
end

function M.tmux_split_horizontal()
	vim.fn.system('tmux split-window -v -c "#{pane_current_path}"')
end

function M.tmux_split_vertical()
	vim.fn.system('tmux split-window -h -c "#{pane_current_path}"')
end

function M.OpenInGH()
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

	local branch_cmd = vim.system({ "git", "rev-parse", "--abbrev-ref", "HEAD" }, { cwd = file_dir }):wait()
	local branch = vim.trim(branch_cmd.stdout)
	if branch == "" then
		branch = "HEAD"
	end

	local line_no = vim.api.nvim_win_get_cursor(0)[1]
	local url = string.format("%s/blob/%s/%s#L%d", base_url, branch, rel_path, line_no)

	local open_cmd = vim.fn.has("mac") == 1 and "open" or "xdg-open"
	vim.system({ open_cmd, url })
end

return M
