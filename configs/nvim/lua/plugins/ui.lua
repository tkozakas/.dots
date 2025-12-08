return {
	"stevearc/oil.nvim",
	lazy = false,
	dependencies = { "nvim-telescope/telescope.nvim" },
	opts = {
		lsp_file_methods = { enabled = false },
		view_options = { show_hidden = true },
		watch_for_changes = true,
		delete_to_trash = true,
		skip_confirm_for_simple_edits = true,
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
					else
						oil.select()
					end
				end,
			},
		},
	},
	config = function(_, opts)
		local funcs = require("core.functions")

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

		vim.api.nvim_create_autocmd({ "BufEnter", "DirChanged" }, {
			callback = function(args)
				local buftype = vim.bo[args.buf].buftype
				local filetype = vim.bo[args.buf].filetype
				
				if filetype == "oil" then
					local oil = require("oil")
					local dir = oil.get_current_dir()
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
				if vim.fn.isdirectory(filedir) == 1 and vim.fn.getcwd() ~= filedir then
					vim.cmd.cd(filedir)
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
				vim.keymap.set("n", "<leader>g", funcs.lazygit, {
					buffer = args.buf,
					desc = "Open Lazygit (from Oil)",
				})
			end,
		})
	end,
}
