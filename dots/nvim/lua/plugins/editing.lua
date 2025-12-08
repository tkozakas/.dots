return {
	"tpope/vim-sleuth",

	{ "windwp/nvim-autopairs", config = true },

	"vim-scripts/groovy.vim",

	{
		"Wansmer/treesj",
		lazy = false,
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
		"pocco81/auto-save.nvim",
		opts = {
			enabled = true,
			trigger_events = { "InsertLeave" },
			execution_message = { message = "" },
			condition = function(buf)
				if not vim.api.nvim_buf_is_valid(buf) then
					return false
				end
				if vim.bo[buf].filetype == "harpoon" then
					return false
				end
				return true
			end,
		},
	},

	{
		"ThePrimeagen/refactoring.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
		},
		config = function()
			require("refactoring").setup({})
			-- Extract function keymaps
			vim.keymap.set("x", "<leader>re", function()
				require("refactoring").refactor("Extract Function")
			end, { desc = "[R]efactor [E]xtract function" })
			-- Extract variable
			vim.keymap.set("x", "<leader>rv", function()
				require("refactoring").refactor("Extract Variable")
			end, { desc = "[R]efactor extract [V]ariable" })
		end,
	},

	{
		"mbbill/undotree",
		keys = {
			{ "<leader>u", vim.cmd.UndotreeToggle, desc = "[U]ndo tree" },
		},
	},
}
