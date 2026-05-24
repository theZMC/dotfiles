---@type LazySpec
return {
  "AstroNvim/astrolsp",
  ---@type AstroLSPOpts
  opts = {
    ---@diagnostic disable: missing-fields
    config = {
      clangd = { capabilities = { offsetEncoding = "utf-8" } },
      jsonls = {
        filetypes = { "json", "jsonc", "json5" },
      },
      gopls = {
        settings = {
          gopls = {
            analyses = {
              shadow = false,
            },
          },
        },
      },
    },
  },
}
