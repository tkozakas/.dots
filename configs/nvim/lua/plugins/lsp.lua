local function ruby_lsp_bin()
  local bin = vim.fn.expand("~/.local/share/mise/shims/ruby-lsp")
  if vim.fn.executable(bin) == 0 then
    bin = vim.fn.expand("~/.rbenv/shims/ruby-lsp")
  end
  if vim.fn.executable(bin) == 0 then
    bin = vim.fn.exepath("ruby-lsp")
  end
  return bin
end

-- JetBrains Cmd+B: on a usage jump to definition; on the definition itself
-- show usages instead.
local function smart_definition()
  local buf = vim.api.nvim_get_current_buf()
  local lnum = vim.api.nvim_win_get_cursor(0)[1] - 1
  local uri = vim.uri_from_bufnr(buf)
  local client = vim.lsp.get_clients({ bufnr = buf, method = "textDocument/definition" })[1]
  if not client then
    return
  end
  local params = vim.lsp.util.make_position_params(0, client.offset_encoding)
  client:request("textDocument/definition", params, function(_, result)
    local locs = result or {}
    if locs.uri or locs.targetUri then
      locs = { locs }
    end
    local at_definition = false
    for _, loc in ipairs(locs) do
      local range = loc.range or loc.targetSelectionRange
      if (loc.uri or loc.targetUri) == uri and range and range.start.line == lnum then
        at_definition = true
        break
      end
    end
    if at_definition then
      Snacks.picker.lsp_references()
    else
      Snacks.picker.lsp_definitions()
    end
  end, buf)
end

return {
  "neovim/nvim-lspconfig",
  opts = function(_, opts)
    opts.servers = vim.tbl_deep_extend("force", opts.servers or {}, {
      ["*"] = {
        keys = {
          { "gd", smart_definition, desc = "Definition / Usages (smart)" },
        },
      },
      gopls = {},
      pyright = {},
      yamlls = {},
      groovyls = {
        mason = false,
        cmd = {
          "/opt/homebrew/opt/openjdk/bin/java",
          "-jar",
          vim.fn.stdpath("config") .. "/lsp-servers/groovy-language-server-all.jar",
        },
        filetypes = { "groovy" },
        root_markers = { "Jenkinsfile", "build.gradle", "settings.gradle", ".git" },
      },
      ruby_lsp = {
        mason = false,
        -- shims resolve Ruby from cwd; spawn in root_dir or Bundler picks the wrong Ruby
        cmd = function(dispatchers, config)
          return vim.lsp.rpc.start({ ruby_lsp_bin() }, dispatchers, { cwd = config.root_dir })
        end,
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
      },
    })
    return opts
  end,
}
