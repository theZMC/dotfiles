if vim.fn.has "nvim-0.12" == 0 then
  local version = vim.version()
  local current = ("%d.%d.%d"):format(version.major, version.minor, version.patch)

  vim.api.nvim_echo({
    {
      ("nvim-next requires Neovim 0.12+ for vim.pack and the built-in LSP config flow. Current version: %s"):format(
        current
      ),
      "ErrorMsg",
    },
  }, true, {})

  return
end

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

require "config"
