local ok, conform = pcall(require, "conform")

if not ok then return end

local languages = require "config.languages.registry"

local formatters_by_ft = {}
local formatters = {}
local format_on_save = {}

for _, language in ipairs(languages) do
  for filetype, names in pairs(language.formatters_by_ft or {}) do
    formatters_by_ft[filetype] = names
  end

  for name, config in pairs(language.formatters or {}) do
    formatters[name] = config
  end

  for filetype, mode in pairs(language.format_on_save or {}) do
    format_on_save[filetype] = mode
  end
end

conform.setup {
  format_on_save = function(bufnr)
    local filetype = vim.bo[bufnr].filetype
    local mode = format_on_save[filetype]

    if mode == false then return nil end

    return {
      timeout_ms = 1000,
      lsp_format = mode or "fallback",
    }
  end,
  formatters_by_ft = formatters_by_ft,
  formatters = formatters,
}
