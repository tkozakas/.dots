return {
	"rmagatti/auto-session",
	lazy = false,
	opts = {
		auto_save = true,
		auto_restore = true,
		suppressed_dirs = { "~/", "/tmp" },
		session_lens = { load_on_setup = false },
		pre_save_cmds = {
			function()
				for _, buf in ipairs(vim.api.nvim_list_bufs()) do
					if vim.bo[buf].filetype == "oil" then
						vim.api.nvim_buf_delete(buf, { force = true })
					end
				end
			end,
		},
	},
}
