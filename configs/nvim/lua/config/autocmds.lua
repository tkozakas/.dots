local function flat_chrome()
  local set = vim.api.nvim_set_hl
  set(0, "WinSeparator", { ctermfg = 8, ctermbg = "NONE", cterm = {} })
  set(0, "StatusLine", { ctermfg = 7, ctermbg = "NONE", cterm = {} })
  set(0, "StatusLineNC", { ctermfg = 8, ctermbg = "NONE", cterm = {} })
  set(0, "EndOfBuffer", { ctermfg = 0, ctermbg = "NONE", cterm = {} })
  set(0, "NormalFloat", { ctermbg = "NONE" })
  set(0, "FloatBorder", { ctermfg = 8, ctermbg = "NONE" })
  set(0, "ColorColumn", { ctermfg = "NONE", ctermbg = "NONE", cterm = {} })
  set(0, "Statement", { ctermfg = 11, cterm = { bold = true } })
  set(0, "Keyword", { link = "Statement" })
  set(0, "Type", { ctermfg = 6 })
  set(0, "Constant", { ctermfg = 13 })
  set(0, "Number", { link = "Constant" })
  set(0, "Boolean", { link = "Constant" })
  set(0, "Comment", { ctermfg = 8 })
  set(0, "PreProc", { ctermfg = 12 })
  set(0, "SnacksPickerMatch", { ctermfg = 11, cterm = { bold = true } })
  set(0, "SnacksPickerSearch", { link = "Search" })
  set(0, "Search", { ctermfg = "NONE", ctermbg = 58, cterm = {} })
  set(0, "CurSearch", { ctermfg = 0, ctermbg = 3, cterm = {} })
  set(0, "IncSearch", { link = "CurSearch" })
  set(0, "LspReferenceText", { ctermfg = "NONE", ctermbg = 238, cterm = {} })
  set(0, "LspReferenceRead", { link = "LspReferenceText" })
  set(0, "LspReferenceWrite", { link = "LspReferenceText" })
  set(0, "MatchParen", { ctermfg = 11, ctermbg = "NONE", cterm = { bold = true } })
  set(0, "Visual", { ctermfg = "NONE", ctermbg = 237, cterm = {} })
  set(0, "VisualNOS", { link = "Visual" })
  set(0, "LspSignatureActiveParameter", { ctermfg = 11, ctermbg = "NONE", cterm = { bold = true } })
  set(0, "SnippetTabstop", { ctermfg = "NONE", ctermbg = 237, cterm = {} })
  set(0, "SnippetTabstopActive", { link = "SnippetTabstop" })
  set(0, "DapStoppedLine", { ctermfg = "NONE", ctermbg = 238, cterm = {} })
  set(0, "Pmenu", { ctermfg = "NONE", ctermbg = "NONE" })
  set(0, "PmenuSel", { ctermbg = 237, cterm = { bold = true } })
  set(0, "BlinkCmpLabelMatch", { ctermfg = 11, cterm = { bold = true } })
  set(0, "PmenuThumb", { ctermbg = 8 })
  set(0, "BlinkCmpMenu", { link = "Pmenu" })
  set(0, "BlinkCmpMenuBorder", { link = "FloatBorder" })
  set(0, "BlinkCmpMenuSelection", { link = "PmenuSel" })
  set(0, "BlinkCmpDoc", { link = "NormalFloat" })
  set(0, "BlinkCmpDocBorder", { link = "FloatBorder" })
  set(0, "CopilotSuggestion", { ctermfg = 8, cterm = { italic = true } })
  set(0, "CopilotAnnotation", { ctermfg = 8 })
  set(0, "GitSignsAdd", { ctermfg = 2 })
  set(0, "GitSignsChange", { ctermfg = 12 })
  set(0, "GitSignsDelete", { ctermfg = 9 })
  set(0, "GitSignsChangedelete", { link = "GitSignsChange" })
  set(0, "GitSignsTopdelete", { link = "GitSignsDelete" })
  set(0, "GitSignsUntracked", { ctermfg = 8 })
end

vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup("flat-chrome", { clear = true }),
  callback = flat_chrome,
})
flat_chrome()

vim.api.nvim_create_autocmd("LspProgress", {
  group = vim.api.nvim_create_augroup("lsp-progress-notify", { clear = true }),
  callback = function(ev)
    local value = ev.data.params.value
    if type(value) ~= "table" then
      return
    end
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    local text = vim.trim((value.title or "") .. " " .. (value.message or ""))
    if value.percentage then
      text = text .. " " .. value.percentage .. "%"
    end
    vim.notify(text, vim.log.levels.INFO, {
      id = "lsp_progress_" .. ev.data.client_id,
      title = client and client.name or "lsp",
      opts = function(notif)
        notif.icon = value.kind == "end" and "✓" or "…"
      end,
    })
  end,
})
