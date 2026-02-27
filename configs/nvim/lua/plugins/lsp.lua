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

					map("gd", vim.lsp.buf.definition, "LSP: Go to definition")
					map("gr", vim.lsp.buf.references, "LSP: Go to references")
					map("<leader>rn", vim.lsp.buf.rename, "LSP: Rename symbol")
					map("<leader>ca", vim.lsp.buf.code_action, "[C]ode: [A]ction", { "n", "x" })
					map("<leader>h", vim.lsp.buf.hover, "LSP: Hover documentation")
				end,
			})

			local capabilities = vim.lsp.protocol.make_client_capabilities()
			capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

			vim.lsp.config("*", {
				capabilities = capabilities,
			})

			vim.lsp.config("yamlls", {})
			vim.lsp.config("gopls", {})
			vim.lsp.config("pyright", {})

			vim.lsp.config("ruby_lsp", {
				cmd = { "mise", "x", "--", "ruby-lsp" },
				filetypes = { "ruby" },
				root_markers = { "Gemfile", ".git" },
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
			})

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
					"isort",
					"black",
				}),
			})

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
				timeout_ms = 500,
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
				if vim.bo.filetype == "oil" then
					local dir = require("oil").get_current_dir()
					if not dir then
						return
					end
					vim.notify("Formatting: " .. dir, vim.log.levels.INFO)
					local cmds = {
						{ cmd = { "black", dir } },
						{ cmd = { "gofmt", "-w", dir } },
						{ cmd = { "stylua", dir } },
						{ cmd = { "prettier", "--write", dir } },
						{ cmd = { "rubocop", "-a", dir } },
						{ cmd = { "shfmt", "-w", dir } },
					}
					for _, c in ipairs(cmds) do
						vim.fn.jobstart(c.cmd, { detach = true })
					end
				else
					require("conform").format({ async = true, lsp_format = "fallback" })
				end
			end, { desc = "[F]ormat file or directory" })
		end,
	},
}
