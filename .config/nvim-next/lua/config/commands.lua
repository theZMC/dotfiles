vim.api.nvim_create_user_command(
  "PackUpdate",
  function() vim.pack.update() end,
  { desc = "Update plugins managed by vim.pack" }
)

vim.api.nvim_create_user_command(
  "LazyGit",
  function() require("config.terminal").lazygit() end,
  { desc = "Open lazygit in a floating terminal" }
)

vim.api.nvim_create_user_command("Format", function()
  local ok, conform = pcall(require, "conform")
  local filetype = vim.bo.filetype

  if ok then
    conform.format {
      async = false,
      lsp_format = filetype == "astro" and "never" or "fallback",
    }
    return
  end

  vim.lsp.buf.format { async = false }
end, { desc = "Format current buffer" })
