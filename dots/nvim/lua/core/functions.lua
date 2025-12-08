M = {}

function M.open_or_create_pr()
	local file_dir
	if vim.bo.filetype == "oil" then
		file_dir = require("oil").get_current_dir()
	else
		file_dir = vim.fn.expand("%:p:h")
	end

	if file_dir == "" or file_dir == nil then
		vim.notify("Cannot determine file directory.", vim.log.levels.WARN)
		return
	end

	local gh_command = "CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD) && "
		.. "DEFAULT_BRANCH=$(gh repo view --json defaultBranchRef --jq '.defaultBranchRef.name') && "
		.. 'if [ "$CURRENT_BRANCH" = "$DEFAULT_BRANCH" ]; then exit 1; fi && '
		.. 'git push --set-upstream origin "$CURRENT_BRANCH" && '
		.. "OPEN_PR_COUNT=$(gh pr list --head \"$CURRENT_BRANCH\" --state open --limit 1 --json url --jq 'length') && "
		.. 'if [ "$OPEN_PR_COUNT" -eq 0 ]; then '
		.. "gh pr create --fill --web; "
		.. "else "
		.. "gh pr view --web; "
		.. "fi"

	local silent_command = "(" .. gh_command .. ") >/dev/null 2>&1"

	vim.system({ "sh", "-c", silent_command }, {
		cwd = file_dir,
	})
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
	vim.fn.system("tmux split-window -v -c '#{pane_current_path}'")
end

function M.tmux_split_vertical()
	vim.fn.system("tmux split-window -h -c '#{pane_current_path}'")
end

function M.OpenInGH()
	local git_cmd = vim.system({ "git", "remote", "get-url", "origin" }):wait()

	if git_cmd["code"] ~= 0 then
		vim.notify("Not a git repository or origin is not set")
		return
	end

	local remote = git_cmd.stdout:gsub("\n", ""):gsub("^git@", ""):gsub("%.git$", ""):gsub(":", "/")
	local current_file = vim.fn.expand("%:.")
	local line_no, _ = unpack(vim.api.nvim_win_get_cursor(0))

	local url = string.format("https://%s/blob/master/%s#L%d", remote, current_file, line_no)
	vim.system({ "open", url })
end

return M
