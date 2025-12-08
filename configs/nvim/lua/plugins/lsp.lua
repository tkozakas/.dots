return {
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			{ "williamboman/mason.nvim", config = true },
			"williamboman/mason-lspconfig.nvim",
			"WhoIsSethDaniel/mason-tool-installer.nvim",
			"hrsh7th/cmp-nvim-lsp",
		},
		config = function()
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
				callback = function(event)
					local map = function(keys, func, mode)
						mode = mode or "n"
						vim.keymap.set(mode, keys, func, { buffer = event.buf })
					end

					map("gd", vim.lsp.buf.definition)
					map("<leader>rn", vim.lsp.buf.rename)
					map("<leader>.", vim.lsp.buf.code_action, { "n", "x" })
					map("<leader>h", vim.lsp.buf.hover)
					map("<leader>en", vim.diagnostic.goto_next)
					map("<leader>ep", vim.diagnostic.goto_prev)
				end,
			})

			local capabilities = vim.lsp.protocol.make_client_capabilities()
			capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

			-- Configure LSP servers using vim.lsp.config
			vim.lsp.config("*", {
				capabilities = capabilities,
			})

			vim.lsp.config.yamlls = {}
			vim.lsp.config.gopls = {}
			vim.lsp.config.pyright = {}

			vim.lsp.config.ruby_lsp = {
				cmd = { "mise", "x", "--", "ruby-lsp" },
				filetypes = { "ruby" },
				root_markers = { "Gemfile", ".git" },
				settings = {},
			}

			vim.lsp.config.groovyls = {
				cmd = {
					"java",
					"-jar",
					vim.fn.stdpath("config") .. "/lsp-servers/groovy-language-server-all.jar",
				},
				filetypes = { "groovy", "Jenkinsfile" },
				root_markers = {
					"Jenkinsfile",
					"build.gradle",
					"settings.gradle",
					".git"
				},
			}

			vim.lsp.config.lua_ls = {
				on_init = function(client)
					if client.workspace_folders then
						local path = client.workspace_folders[1].name
						if
							vim.loop.fs_stat(path .. "/.luarc.json")
							or vim.loop.fs_stat(path .. "/.luarc.jsonc")
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
			}

			require("mason").setup()

			local servers = {
				"yamlls",
				"gopls",
				"pyright",
				"lua_ls",
			}

			require("mason-tool-installer").setup({
				ensure_installed = vim.list_extend(vim.deepcopy(servers), {
					"stylua",
				})
			})

			require("mason-lspconfig").setup({
				ensure_installed = servers,
				handlers = {
					function(server_name)
						vim.lsp.enable(server_name)
					end,
				},
			})

			-- Enable non-Mason LSP servers
			vim.lsp.enable("ruby_lsp")
			vim.lsp.enable("groovyls")

			vim.lsp.handlers["textDocument/publishDiagnostics"] =
				vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
				virtual_text = {
					spacing = 4,
					prefix = "●",
				},
					signs = false,
					underline = false,
					update_in_insert = false,
				})
		end,
	},
	{
		"stevearc/conform.nvim",
		event = "BufWritePre",
		cmd = { "ConformInfo" },
		opts = {
			notify_on_error = false,
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
				ruby = { "rubocop" },
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
				require("conform").format({ async = true, lsp_format = "fallback" })
			end)
		end,
	},
}
