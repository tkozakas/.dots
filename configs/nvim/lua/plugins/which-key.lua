return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	opts = {
		delay = 300,
		icons = { mappings = false },
		spec = {
			{ "<leader>b", group = "buffer" },
			{ "<leader>c", group = "code" },
			{ "<leader>d", group = "diagnostics" },
			{ "<leader>g", group = "git" },
			{ "<leader>l", group = "lsp" },
			{ "<leader>o", group = "other file" },
			{ "<leader>r", group = "refactor" },
			{ "<leader>s", group = "search" },
			{ "<leader>t", group = "test" },
			{ "<leader>x", group = "debug" },
		},
	},
}
