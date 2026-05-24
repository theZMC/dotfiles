---@type LazySpec
return {
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    opts = {
      ensure_installed = {
        "yamlfmt",
        "hclfmt",
      },
    },
  },
}
