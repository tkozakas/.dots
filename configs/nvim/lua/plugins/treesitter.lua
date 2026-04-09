return {
	"nvim-treesitter/nvim-treesitter",
	dependencies = { "RRethy/nvim-treesitter-endwise" },
	build = ":TSUpdate",
	main = "nvim-treesitter.configs",
	event = { "BufReadPost", "BufNewFile" },
	opts = {
		ensure_installed = {
			"bash",
			"diff",
			"html",
			"lua",
			"luadoc",
			"query",
			"vim",
			"vimdoc",
			"json",
			"go",
			"ruby",
			"nix",
			"groovy",
			"python",
			"yaml",
		},
		auto_install = true,
		highlight = {
			enable = true,
			disable = function(_, buf)
				local max_filesize = 1024 * 1024 -- 1 MB
				local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(buf))
				return ok and stats and stats.size > max_filesize
			end,
		},
		indent = { enable = true, disable = { "ruby" } },
		endwise = { enable = true },
	},
}
