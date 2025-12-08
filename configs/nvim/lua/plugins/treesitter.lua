return {
	"nvim-treesitter/nvim-treesitter",
	dependencies = { "RRethy/nvim-treesitter-endwise" },
	build = ":TSUpdate",
	main = "nvim-treesitter.configs",
	event = "VeryLazy",
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
		},
		auto_install = true,
		highlight = { enable = true },
		indent = { enable = true, disable = { "ruby" } },
		endwise = { enable = true },
	},
	config = function(_, opts)
		require("nvim-treesitter.configs").setup(opts)
	end,
}
