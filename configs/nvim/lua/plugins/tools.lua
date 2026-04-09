return {
	{
		"lewis6991/gitsigns.nvim",
		event = { "BufReadPost", "BufNewFile" },
		opts = {
			signs = {
				add = { text = "▎" },
				change = { text = "▎" },
				delete = { text = "" },
				topdelete = { text = "" },
				changedelete = { text = "▎" },
				untracked = { text = "▎" },
			},
			linehl = false,
			numhl = true,
			current_line_blame = false,
			current_line_blame_opts = {
				delay = 1000,
			},
			on_attach = function(bufnr)
				local gs = require("gitsigns")
				local function map(mode, l, r, desc)
					vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
				end
				map("n", "]h", function() gs.nav_hunk("next") end, "Next hunk")
				map("n", "[h", function() gs.nav_hunk("prev") end, "Prev hunk")
				map("n", "<leader>gs", gs.stage_hunk, "Git: [S]tage hunk")
				map("n", "<leader>gr", gs.reset_hunk, "Git: [R]eset hunk")
				map("v", "<leader>gs", function() gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Git: [S]tage hunk")
				map("v", "<leader>gr", function() gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Git: [R]eset hunk")
				map("n", "<leader>gS", gs.stage_buffer, "Git: [S]tage buffer")
				map("n", "<leader>gu", gs.undo_stage_hunk, "Git: [U]ndo stage")
				map("n", "<leader>gd", gs.diffthis, "Git: [D]iff this")
				map("n", "<leader>gb", gs.blame_line, "Git: [B]lame line")
			end,
		},
	},
	{
		"ThePrimeagen/harpoon",
		branch = "harpoon2",
		dependencies = { "nvim-lua/plenary.nvim" },
		keys = {
			{ "M", function() require("harpoon"):list():add() end, desc = "Harpoon: add file" },
			{ "mm", function() require("harpoon").ui:toggle_quick_menu(require("harpoon"):list()) end, desc = "Harpoon: toggle menu" },
			{ "ma", function() require("harpoon"):list():select(1) end, desc = "Harpoon: file 1" },
			{ "ms", function() require("harpoon"):list():select(2) end, desc = "Harpoon: file 2" },
			{ "md", function() require("harpoon"):list():select(3) end, desc = "Harpoon: file 3" },
			{ "mf", function() require("harpoon"):list():select(4) end, desc = "Harpoon: file 4" },
		},
		config = function()
			require("harpoon"):setup()
		end,
	},
	{
		"nvim-neotest/neotest",
		dependencies = {
			"nvim-neotest/nvim-nio",
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
			"olimorris/neotest-rspec",
			"fredrikaverpil/neotest-golang",
		},
		keys = {
			{
				"<leader>tn",
				function()
					require("neotest").run.run()
				end,
				desc = "Test: run [N]earest",
			},
			{
				"<leader>tf",
				function()
					require("neotest").run.run(vim.fn.expand("%"))
				end,
				desc = "Test: run [F]ile",
			},
			{
				"<leader>ta",
				function()
					require("neotest").run.run({ suite = true })
				end,
				desc = "Test: run [A]ll",
			},
			{
				"<leader>ts",
				function()
					require("neotest").summary.toggle()
				end,
				desc = "Test: [S]ummary",
			},
			{
				"<leader>to",
				function()
					require("neotest").output_panel.toggle()
				end,
				desc = "Test: [O]utput",
			},
			{
				"<leader>tx",
				function()
					require("neotest").run.stop()
				end,
				desc = "Test: [X] stop",
			},
		},
		config = function()
			require("neotest").setup({
				adapters = {
					require("neotest-rspec")({
					rspec_cmd = function()
						return { "bundle", "exec", "rspec" }
					end,
					}),
					require("neotest-golang"),
				},
			})
		end,
	},
	{
		"rgroli/other.nvim",
		keys = {
			{ "<leader>o", function() require("other-nvim").open() end, desc = "Open [O]ther file" },
			{ "<leader>O", function() require("other-nvim").openVSplit() end, desc = "Open [O]ther file (vsplit)" },
		},
		config = function()
			require("other-nvim").setup({
				mappings = {
					"golang",
					"python",
					{
						pattern = "/app/(.*)/(.*).rb",
						target = {
							{ context = "test", target = "/spec/%1/%2_spec.rb" },
						},
					},
					{
						pattern = "(.+)/spec/(.*)/(.*)_spec.rb",
						target = {
							{ target = "%1/app/%2/%3.rb" },
						},
					},
				},
			})
		end,
	},
}
