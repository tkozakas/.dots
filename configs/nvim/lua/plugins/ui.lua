return {
	"stevearc/oil.nvim",
	lazy = false,
	dependencies = { "nvim-telescope/telescope.nvim" },
	opts = {
		lsp_file_methods = { enabled = false },
		view_options = { show_hidden = true },
		watch_for_changes = true,
		delete_to_trash = true,
		skip_confirm_for_simple_edits = false,
		prompt_save_on_select_new_entry = true,
		keymaps = {
			["<CR>"] = {
				callback = function()
					local oil = require("oil")
					local entry = oil.get_cursor_entry()
					if entry and entry.type == "directory" then
						oil.select()
						vim.schedule(function()
							local dir = oil.get_current_dir()
							if dir then
								vim.cmd.cd(dir)
							end
						end)
					elseif entry and entry.type == "file" then
						local name = entry.name
						local ext = name:match("%.([^%.]+)$")
						if ext then
							ext = ext:lower()
						end
						local media_exts = {
							png = true, jpg = true, jpeg = true, gif = true, bmp = true,
							webp = true, svg = true, ico = true, tiff = true, tif = true,
							mp4 = true, mkv = true, avi = true, mov = true, wmv = true,
							flv = true, webm = true, m4v = true, mpeg = true, mpg = true,
						}
						if ext and media_exts[ext] then
							local dir = oil.get_current_dir()
							local filepath = dir .. name
							local open_cmd = vim.fn.has("mac") == 1 and "open" or "xdg-open"
							vim.fn.jobstart({ open_cmd, filepath }, { detach = true })
						else
							oil.select()
						end
					else
						oil.select()
					end
				end,
			},
		},
	},
	config = function(_, opts)
		require("oil").setup(opts)
		vim.keymap.set("n", "<leader>e", require("oil").open, { desc = "Open file explorer" })

		vim.api.nvim_create_autocmd("VimLeavePre", {
			callback = function()
				local cwd = vim.fn.getcwd()
				local file = io.open(vim.fn.expand("$HOME") .. "/.nvim_last_dir", "w")
				if file then
					file:write(cwd)
					file:close()
				end
			end,
		})

		-- Auto-cd to git root (or file dir if not in a repo)
		vim.api.nvim_create_autocmd({ "BufEnter", "DirChanged" }, {
			callback = function(args)
				local buftype = vim.bo[args.buf].buftype
				local filetype = vim.bo[args.buf].filetype

				if filetype == "oil" then
					local dir = require("oil").get_current_dir()
					if dir and vim.fn.getcwd() ~= dir then
						vim.cmd.cd(dir)
					end
					return
				end

				if buftype ~= "" and buftype ~= "acwrite" then
					return
				end

				local filepath = vim.api.nvim_buf_get_name(args.buf)
				if filepath == "" then
					return
				end

				local filedir = vim.fn.fnamemodify(filepath, ":h")
				local git_root = vim.fn.systemlist("git -C " .. vim.fn.shellescape(filedir) .. " rev-parse --show-toplevel 2>/dev/null")[1]
				local target = (git_root and git_root ~= "" and vim.v.shell_error == 0) and git_root or filedir

				if vim.fn.isdirectory(target) == 1 and vim.fn.getcwd() ~= target then
					vim.cmd.cd(target)
				end
			end,
		})

		vim.api.nvim_create_autocmd("FileType", {
			pattern = "oil",
			callback = function(args)
				vim.keymap.set("n", "<leader>ff", require("telescope.builtin").find_files, {
					buffer = args.buf,
					desc = "[F]ind [F]iles (from Oil)",
				})
				vim.keymap.set("n", "<leader>sg", require("telescope").extensions.live_grep_args.live_grep_args, {
					buffer = args.buf,
					desc = "[S]earch [G]rep (from Oil)",
				})
				vim.keymap.set("n", "<leader>gg", require("core.functions").lazygit, {
					buffer = args.buf,
					desc = "[G]it: Open [G]UI (from Oil)",
				})
			end,
		})
	end,
}
