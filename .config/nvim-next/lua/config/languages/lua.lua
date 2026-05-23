return {
  lsp = {
    {
      name = "lua_ls",
      cmd = "lua-language-server",
      config = {
        settings = {
          Lua = {
            completion = {
              callSnippet = "Replace",
            },
            diagnostics = {
              globals = { "vim" },
            },
            workspace = {
              checkThirdParty = false,
            },
          },
        },
      },
    },
  },
  formatters_by_ft = {
    lua = { "stylua" },
  },
}
