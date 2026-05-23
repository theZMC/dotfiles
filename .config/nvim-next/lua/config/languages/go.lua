return {
  lsp = {
    {
      name = "gopls",
      cmd = "gopls",
      config = {
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
