return {
	"stevearc/oil.nvim",
	lazy = false,
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
						local ext = entry.name:match("%.([^%.]+)$")
						if ext then ext = ext:lower() end
						local media_exts = {
							png = true, jpg = true, jpeg = true, gif = true, bmp = true,
							webp = true, svg = true, ico = true, tiff = true, tif = true,
							mp4 = true, mkv = true, avi = true, mov = true, wmv = true,
							flv = true, webm = true, m4v = true, mpeg = true, mpg = true,
						}
						if ext and media_exts[ext] then
						local filepath = oil.get_current_dir() .. entry.name
						local open_cmd = require("core.functions").open_cmd()
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
	end,
}
