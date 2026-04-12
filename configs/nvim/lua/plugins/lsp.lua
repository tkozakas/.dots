return {
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPost", "BufNewFile" },
		dependencies = {
			{ "williamboman/mason.nvim", config = true },
			"williamboman/mason-lspconfig.nvim",
			"WhoIsSethDaniel/mason-tool-installer.nvim",
			"hrsh7th/cmp-nvim-lsp",
		},
		config = function()
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
				callback = function(event)
					local function map(keys, func, desc, mode)
						mode = mode or "n"
						vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = desc })
					end

				map("gd", vim.lsp.buf.definition, "[G]oto [D]efinition")
				map("<leader>lr", vim.lsp.buf.references, "[L]SP [R]eferences")
				map("<leader>rn", vim.lsp.buf.rename, "[R]e[N]ame symbol")
				map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction", { "n", "x" })
				-- K → vim.lsp.buf.hover is built-in since Neovim 0.10
				end,
			})

			local capabilities = vim.lsp.protocol.make_client_capabilities()
			capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

			vim.lsp.config("*", {
				capabilities = capabilities,
			})

		vim.lsp.config("ruby_lsp", {
				cmd = { vim.fn.expand("~/.rbenv/shims/ruby-lsp") },
				filetypes = { "ruby", "eruby" },
				root_markers = { "Gemfile", ".git" },
				init_options = {
					formatter = "rubocop",
					linters = { "rubocop" },
					indexing = {
						excludedPatterns = { "**/test/**/*.rb", "**/spec/fixtures/**/*.rb" },
						excludedGems = {
							"actioncable",
							"actionmailbox",
							"actiontext",
							"activestorage",
							"aws-sdk-*",
							"brakeman",
							"byebug",
							"factory_bot",
							"faker",
							"pry",
							"rubocop",
							"rubocop-performance",
							"rubocop-rails",
							"rspec",
							"rspec-core",
							"rspec-expectations",
							"rspec-mocks",
							"rspec-rails",
							"simplecov",
							"webmock",
						},
					},
				},
			})

			vim.lsp.config("groovyls", {
				cmd = {
					"/opt/homebrew/opt/openjdk/bin/java",
					"-jar",
					vim.fn.stdpath("config") .. "/lsp-servers/groovy-language-server-all.jar",
				},
				filetypes = { "groovy" },
				root_markers = {
					"Jenkinsfile",
					"build.gradle",
					"settings.gradle",
					".git",
				},
			})

			vim.lsp.config("lua_ls", {
				on_init = function(client)
					if client.workspace_folders then
						local path = client.workspace_folders[1].name
						if
						vim.uv.fs_stat(path .. "/.luarc.json")
						or vim.uv.fs_stat(path .. "/.luarc.jsonc")
						then
							return
						end
					end

					client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
						runtime = { version = "LuaJIT" },
						workspace = {
							checkThirdParty = false,
							library = { vim.env.VIMRUNTIME },
						},
					})
				end,
				settings = {
					Lua = {},
				},
			})

			require("mason").setup()

			local servers = {
				"yamlls",
				"gopls",
				"pyright",
				"lua_ls",
			}

		local tools = vim.list_extend(vim.deepcopy(servers), { "stylua", "isort", "black" })
		require("mason-tool-installer").setup({ ensure_installed = tools })

			require("mason-lspconfig").setup({
				ensure_installed = servers,
				handlers = {
					function(server_name)
						vim.lsp.enable(server_name)
					end,
				},
			})

			vim.lsp.enable("ruby_lsp")
			vim.lsp.enable("groovyls")
		end,
	},
	{
		"stevearc/conform.nvim",
		event = "BufWritePre",
		cmd = { "ConformInfo" },
		opts = {
			notify_on_error = false,
			format_on_save = {
				timeout_ms = 5000,
				lsp_format = "fallback",
			},
			formatters_by_ft = {
				lua = { "stylua" },
				go = { "gofmt", "goimports" },
				python = { "isort", "black" },
				javascript = { "prettier" },
				typescript = { "prettier" },
				javascriptreact = { "prettier" },
				typescriptreact = { "prettier" },
				vue = { "prettier" },
				css = { "prettier" },
				scss = { "prettier" },
				less = { "prettier" },
				html = { "prettier" },
				json = { "prettier" },
				jsonc = { "prettier" },
				yaml = { "prettier" },
				markdown = { "prettier" },
				graphql = { "prettier" },
				-- ruby: formatting handled by ruby_lsp (rubocop via linters init_option)
				rust = { "rustfmt" },
				c = { "clang-format" },
				cpp = { "clang-format" },
				proto = { "buf" },
				terraform = { "terraform_fmt" },
				sh = { "shfmt" },
				bash = { "shfmt" },
				groovy = { "prettier" },
			},
		},
		config = function(_, opts)
			require("conform").setup(opts)
			vim.keymap.set({ "n", "v" }, "<leader>f", function()
				if vim.bo.filetype == "oil" then
					local dir = require("oil").get_current_dir()
					if not dir then
						return
					end
					vim.notify("Formatting: " .. dir, vim.log.levels.INFO)
				local cmds = {
					{ "black", dir },
					{ "gofmt", "-w", dir },
					{ "stylua", dir },
					{ "prettier", "--write", dir },
					{ "rubocop", "-a", dir },
					{ "shfmt", "-w", dir },
				}
				for _, args in ipairs(cmds) do
					vim.fn.jobstart(args, { detach = true })
				end
				else
					require("conform").format({ async = true, lsp_format = "fallback" })
				end
			end, { desc = "[F]ormat file or directory" })
		end,
	},
}
