return {
	"tpope/vim-sleuth",

	{ "windwp/nvim-autopairs", event = "InsertEnter", config = true },

	{ "vim-scripts/groovy.vim", ft = "groovy" },

	{
		"Wansmer/treesj",
		config = function()
			require("treesj").setup({
				use_default_keymaps = false,
				max_join_length = 80,
			})
		end,
		keys = {
			{
				"<leader>/",
				function()
					require("treesj").toggle()
				end,
			},
		},
	},

	{
		"ThePrimeagen/refactoring.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
		},
		keys = {
			{
				"<leader>re",
				function()
					return require("refactoring").refactor("Extract Function")
				end,
				mode = { "n", "x" },
				expr = true,
				desc = "[R]efactor [E]xtract function",
			},
			{
				"<leader>rv",
				function()
					return require("refactoring").refactor("Extract Variable")
				end,
				mode = { "n", "x" },
				expr = true,
				desc = "[R]efactor extract [V]ariable",
			},
			{
				"<leader>ri",
				function()
					return require("refactoring").refactor("Inline Variable")
				end,
				mode = { "n", "x" },
				expr = true,
				desc = "[R]efactor [I]nline variable",
			},
		},
		opts = {},
	},

	{
		"mbbill/undotree",
		keys = {
			{ "<leader>u", vim.cmd.UndotreeToggle, desc = "[U]ndo tree" },
		},
	},
}
