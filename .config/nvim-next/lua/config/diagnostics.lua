for name, text in pairs {
  Error = "E",
  Warn = "W",
  Info = "I",
  Hint = "H",
} do
  local hl = "DiagnosticSign" .. name
  vim.fn.sign_define(hl, { text = text, texthl = hl, numhl = "" })
end

vim.diagnostic.config {
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  virtual_text = false,
  -- Current-line virtual lines is the closest built-in replacement for the
  -- Astro recipe plus tiny-inline-diagnostic.
  virtual_lines = { current_line = true },
  float = {
    border = "rounded",
    source = "if_many",
  },
}
